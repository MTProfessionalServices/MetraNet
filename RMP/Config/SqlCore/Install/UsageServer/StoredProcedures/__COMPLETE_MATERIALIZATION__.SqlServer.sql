
/* ===========================================================
1) Copy billing group data from temporary tables to system tables.
2) Update t_billgroup_member_history
3) Update the materialization in 
    t_billgroup_materialization to 'Succeeded'
4) Delete data from temporary tables.

Return:
-1 if unknown error occurred
-2 if each billing group in t_billgroup does not have atleast one account
-3 if something went wrong while executing RefreshBillingGroupConstraints
-4 if something went wrong while executing CleanupMaterialization sproc
=========================================================== */
CREATE PROCEDURE CompleteMaterialization
(
  @id_materialization INT,
  @dt_end DATETIME,
  @status INT OUTPUT
)
AS

BEGIN
   declare @v_sampling_ratio as int;  
    declare @v_table_name as varchar(128);
    declare @v_status as int;
    
     -- initialize @status to failure (-1)
    SET @status = -1 
    SET @v_sampling_ratio = 0
    
   /* ESR-2814 & ESR-3553 analyze table */  
   --update statistics t_billgroup_tmp with sample 20 percent ;
  set  @v_table_name = 't_billgroup_tmp';   
  exec mt_sys_analyze_table  @v_table_name ,@v_sampling_ratio, @v_status output;
   IF (@v_status != 0) 
       BEGIN
          SET @status = -1
          RETURN 
       END
       
   /* ESR-2814 & ESR-3553 analyze table */  
  set @v_table_name = 't_billgroup_member_tmp';   
  exec  mt_sys_analyze_table  @v_table_name ,@v_sampling_ratio,  @v_status output;
   IF (@v_status != 0) 
       BEGIN
          SET @status = -1
          RETURN 
       END 

   BEGIN TRAN
   -- copy data from t_billgroup_tmp to t_billgroup
   INSERT INTO t_billgroup (id_billgroup, tx_name, tx_description, id_usage_interval, id_parent_billgroup, tx_type, id_partition)
   SELECT bgt.id_billgroup, bgt.tx_name, bgt.tx_description, bgm.id_usage_interval, bgm.id_parent_billgroup, bgm.tx_type, bgt.id_partition
   FROM t_billgroup_tmp bgt    
   INNER JOIN t_billgroup_materialization bgm ON bgm.id_materialization = bgt.id_materialization
   WHERE bgm.id_materialization = @id_materialization

	--create temp table to hold all the ancestor accounts
  DECLARE @RootBillGroup TABLE (id_billgroup int primary key,id_root_billgroup int)
  INSERT INTO @RootBillGroup select id_billgroup,dbo.GetBillingGroupAncestor(id_billgroup) from t_billgroup_tmp
-- copy data from t_billgroup_member_tmp to t_billgroup_member
  INSERT INTO t_billgroup_member (id_billgroup, id_acc, id_materialization, id_root_billgroup)
  SELECT bgt.id_billgroup, 
              bgmt.id_acc, 
              @id_materialization, 
              rg.id_root_billgroup
  FROM t_billgroup_member_tmp bgmt
  INNER JOIN t_billgroup_tmp bgt 
     ON bgt.tx_name = bgmt.tx_name  
  inner join @RootBillGroup rg on rg.id_billgroup = bgt.id_billgroup
  WHERE bgmt.id_materialization =  @id_materialization AND
              bgt.id_materialization = @id_materialization  
   

-- update t_billgroup_member_history
  declare @maxdate datetime
  set @maxdate = dbo.MTMaxDate()
  INSERT INTO t_billgroup_member_history (id_billgroup, 
                                                                      id_acc, 
                                                                      id_materialization,
                                                                      tx_status,
                                                                      tt_start,
                                                                      tt_end)
  SELECT bgt.id_billgroup, 
              bgmt.id_acc, 
              @id_materialization,
              'Succeeded',
              @dt_end,
              @maxdate
  FROM t_billgroup_member_tmp bgmt
  INNER JOIN t_billgroup_tmp bgt 
     ON bgt.tx_name = bgmt.tx_name  
  WHERE bgmt.id_materialization =  @id_materialization AND
              bgt.id_materialization = @id_materialization   

  -- store the id_usage_interval
  DECLARE @id_usage_interval INT
  SELECT @id_usage_interval = id_usage_interval
  FROM t_billgroup_materialization
  WHERE id_materialization = @id_materialization
  
  /* Copy over billing group constraints */
  EXEC ResetBillingGroupConstraints @id_usage_interval, @status OUTPUT
  IF (@status != 0) 
       BEGIN
          SET @status = -2
          ROLLBACK
          RETURN 
       END
   /* Reset status */
   SET @status = -1

   /* Check that each billing group in t_billgroup has atleast one account  */
   IF EXISTS (SELECT bg.id_billgroup
                   FROM t_billgroup bg
                   WHERE bg.id_billgroup NOT IN (SELECT id_billgroup 
                                                                     FROM t_billgroup_member bgm)
					and id_usage_interval = @id_usage_interval)
   BEGIN
      SET @status = -3
      ROLLBACK
      RETURN 
   END

   /* Delete temporary data and update t_billgroup_materialization */
   EXEC CleanupMaterialization @id_materialization, 
                                                @dt_end, 
                                                'Succeeded', 
                                                NULL, 
                                                @status OUTPUT

    IF (@status != 0) 
       BEGIN
          SET @status = -4
          ROLLBACK
          RETURN 
       END

   -- set @status to success
   SET @status = 0 

   COMMIT TRAN

END
