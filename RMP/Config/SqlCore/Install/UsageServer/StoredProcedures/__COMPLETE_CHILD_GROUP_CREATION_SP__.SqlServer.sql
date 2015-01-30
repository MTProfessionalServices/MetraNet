
/* ===========================================================
1) Delete child group accounts for parent billing group from t_billgroup_member
2) Update t_billgroup_member_history to reflect the deletion
3) Insert child billing group data into t_billgroup from t_billgroup_tmp
4) Insert child billing group data into t_billgroup_member
5) Update t_billgroup_member_history to reflect the addition
6) Delete data from t_billgroup_tmp
7) Delete data from t_billgroup_member_tmp
8) Update t_billgroup_materialization

Returns the following error codes:
   -1 : Unknown error occurred
   -2 : The given id_materialization has a NULL id_parent_billgroup
=========================================================== */
CREATE PROCEDURE CompleteChildGroupCreation
(
  @id_materialization INT,
  @dt_end DATETIME,
  @status INT OUTPUT
)
AS

BEGIN
   -- initialize @status to failure (-1)
   SET @status = -1 

   -- BEGIN TRAN
   
   DECLARE @id_parent_billgroup INT
   DECLARE @id_partition INT

   SELECT @id_parent_billgroup = id_parent_billgroup
   FROM t_billgroup_materialization
   WHERE id_materialization = @id_materialization

   /* Error if there is no id_parent_billgroup is NULL */
   IF @id_parent_billgroup IS NULL
      BEGIN
         SET @status = -2
         -- ROLLBACK
         RETURN 
      END

   -- delete child group accounts for parent billing group from t_billgroup_member
   DELETE  bgm
   FROM t_billgroup_member bgm
   INNER JOIN t_billgroup_member_tmp bgmt
      ON bgmt.id_acc = bgm.id_acc
   WHERE bgmt.id_materialization = @id_materialization AND
               bgm.id_billgroup = @id_parent_billgroup
   
   -- update t_billgroup_member_history to reflect the deletion
   UPDATE bgmh
   SET tt_end = @dt_end
   FROM t_billgroup_member_history bgmh 
   INNER JOIN t_billgroup_member_tmp bgmt
      ON bgmt.id_acc = bgmh.id_acc
   WHERE bgmt.id_materialization = @id_materialization AND
               bgmh.id_billgroup = @id_parent_billgroup

   -- get id_partition of the parent bill group
   SELECT @id_partition = id_partition
   FROM t_billgroup bg 
   WHERE id_billgroup = @id_parent_billgroup

   -- insert child billing group data into t_billgroup from t_billgroup_tmp
   INSERT INTO t_billgroup (id_billgroup, 
                                           tx_name, 
                                           tx_description, 
                                           id_usage_interval, 
                                           id_parent_billgroup, 
                                           tx_type,
                                          id_partition)
   SELECT bgt.id_billgroup, 
               bgt.tx_name, 
               bgt.tx_description, 
               bgm.id_usage_interval, 
               bgm.id_parent_billgroup, 
               bgm.tx_type,
               @id_partition
   FROM t_billgroup_tmp bgt    
   INNER JOIN t_billgroup_materialization bgm 
       ON bgm.id_materialization = bgt.id_materialization
   WHERE bgm.id_materialization = @id_materialization
  

   -- insert child billing group data into t_billgroup_member
  INSERT INTO t_billgroup_member (id_billgroup, id_acc, id_materialization, id_root_billgroup)
  SELECT bgt.id_billgroup, bgmt.id_acc, @id_materialization, 
              dbo.GetBillingGroupAncestor(bgt.id_billgroup) 
  FROM t_billgroup_member_tmp bgmt
  INNER JOIN t_billgroup_tmp bgt 
     ON bgt.tx_name = bgmt.tx_name  
  WHERE bgmt.id_materialization =  @id_materialization AND
              bgt.id_materialization = @id_materialization  

   -- update t_billgroup_member_history to reflect the addition
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
              dbo.MTMaxDate()
  FROM t_billgroup_member_tmp bgmt
  INNER JOIN t_billgroup_tmp bgt 
     ON bgt.tx_name = bgmt.tx_name  
  WHERE bgmt.id_materialization =  @id_materialization AND
              bgt.id_materialization = @id_materialization   

   -- set @status to success
   SET @status = 0 

   -- COMMIT TRAN

END
