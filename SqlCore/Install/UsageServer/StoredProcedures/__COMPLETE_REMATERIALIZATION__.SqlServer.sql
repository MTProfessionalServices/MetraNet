
/* ===========================================================
1) Copy billing group data from temporary tables to system tables.
2) Update t_billgroup_member_history
3) Update the materialization in 
    t_billgroup_materialization to 'Succeeded'
4) Delete data from temporary tables.

Returns the following error codes - for the given materialization:
   -1 : Unknown error occurred
   -2 : Cannot create billing group with zero accounts
   -3 : Something went wrong while executing RefreshBillingGroupConstraints
   -4 : Something went wrong while executing CleanupMaterialization sproc
=========================================================== */
CREATE PROCEDURE CompleteReMaterialization
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
   BEGIN TRAN
   -- initialize @status to failure (-1)
   SET @status = -1 
   SET @v_sampling_ratio = 0
   DECLARE @billGroupMemberMoves TABLE (id_materialization_new INT NOT NULL, 
                                                                      id_materialization_old INT NOT NULL,
                                                                      id_acc INT NOT NULL,
                                                                      id_billgroup_new INT NOT NULL,
                                                                      id_billgroup_old INT NOT NULL,
                                                                      billgroup_name_new NVARCHAR(50) NOT NULL,
                                                                      billgroup_name_old NVARCHAR(50) NOT NULL,
                                                                      newStatus VARCHAR(1),
                                                                      oldStatus VARCHAR(1) NOT NULL)
   DECLARE @id_usage_interval INT
   
   -- Get the id_usage_interval for the given @id_materialization
   SELECT @id_usage_interval = id_usage_interval 
   FROM t_billgroup_materialization 
   WHERE id_materialization = @id_materialization

   -- copy billing groups from t_billgroup_tmp to t_billgroup
   -- only if they don't exist in t_billgroup for the interval associated with
   -- this @id_materialization
   INSERT INTO t_billgroup (id_billgroup, tx_name, tx_description, id_usage_interval, id_parent_billgroup, tx_type, id_partition)
   SELECT bgt.id_billgroup, bgt.tx_name, bgt.tx_description,
               bgm.id_usage_interval, bgm.id_parent_billgroup, bgm.tx_type, bgt.id_partition
   FROM t_billgroup_tmp bgt 
   INNER JOIN t_billgroup_materialization bgm 
     ON bgm.id_materialization = bgt.id_materialization   
     WHERE bgt.id_materialization = @id_materialization AND
                 bgt.tx_name NOT IN (SELECT tx_name 
                                                   FROM t_billgroup 
                                                   WHERE id_usage_interval = @id_usage_interval)
    
    /* 
    copy data from t_billgroup_member_tmp (bgmt) to 
    t_billgroup_member(bgm) with the following conditions:
    
    if  (account in bgmt exists in bgm)
    {
       if (billing group for account in bgmt and billing group for account in bgm are not the same)
       {
          if (both billing groups are 'Open')
          {
             (1) 
             Move account to new billing group
             Record 'succeeded'
             (1a) 
             If the old billing group becomes empty (ie. loses all accounts)
             then delete the old billing group and update history associated with it.
          }
          else 
          {
             (2)
             Record 'failed'
          }
       }
    }
    else
    {
       if (account lands in a billing group that's 'Open'')
       {
          (3)
          Move account to bgm
          Record 'succeeded'
       }
       else 
       {
          (4)
          Record 'failed'
       }
    }
   */
       
    /* ESR-2814 & ESR-3553 analyze table */ 
  set @v_table_name = 't_billgroup_member_tmp';   
  exec mt_sys_analyze_table  @v_table_name ,@v_sampling_ratio, @v_status output 
 IF (@v_status != 0) 
       BEGIN
          SET @status = -1
          ROLLBACK
          RETURN 
       END
   
   /* Doing (1) from the above algorithm
        In t_billgroup_member, the id_acc will be unique amongst the billgroups for
        a given interval
   */
   INSERT @billGroupMemberMoves
   SELECT bgmt.id_materialization id_materialization_new, 
               bgmem.id_materialization id_materialization_old,
               bgmt.id_acc, 
               bg1.id_billgroup id_billgroup_new, 
               bg.id_billgroup id_billgroup_old, 
               bg1.tx_name billgroup_name_new,
               bg.tx_name billgroup_name_old,
               bgsNew.status newStatus, 
               bgsOld.status oldStatus
   FROM t_billgroup_member_tmp bgmt
   INNER JOIN t_billgroup_member bgmem
      ON bgmem.id_acc = bgmt.id_acc 
   INNER JOIN t_billgroup bg
      ON bg.id_billgroup = bgmem.id_billgroup AND
            bg.tx_name != bgmt.tx_name
   INNER JOIN t_billgroup_tmp bgt 
      ON bgt.tx_name = bgmt.tx_name AND
            bgt.id_materialization = bgmt.id_materialization
   INNER JOIN t_billgroup bg1
      ON bg1.tx_name = bgmt.tx_name
   LEFT OUTER JOIN vw_all_billing_groups_status bgsNew 
      ON bgsNew.id_billgroup = bg1.id_billgroup
   LEFT OUTER JOIN vw_all_billing_groups_status bgsOld
      ON bgsOld.id_billgroup = bg.id_billgroup
   WHERE 
       bgmt.id_materialization =  @id_materialization AND
       bg.id_billgroup IN (SELECT id_billgroup 
                                     FROM t_billgroup 
                                     WHERE id_usage_interval = @id_usage_interval) AND
       bg1.id_billgroup IN (SELECT id_billgroup 
                                       FROM t_billgroup 
                                       WHERE id_usage_interval = @id_usage_interval)
 
   /* Update history for account */
   UPDATE bgmh
   SET tt_end = @dt_end
   FROM t_billgroup_member_history bgmh 
   INNER JOIN @billGroupMemberMoves bgmt
      ON bgmt.id_acc = bgmh.id_acc AND
            bgmt.id_billgroup_old = bgmh.id_billgroup AND
            bgmt.id_materialization_old = bgmh.id_materialization
   WHERE bgmt.oldStatus = 'O' AND
               (bgmt.newStatus = 'O' OR bgmt.newStatus IS NULL)

   /* Delete account(s) from t_billgroup_member */
   DELETE t_billgroup_member 
   FROM t_billgroup_member bgm
   INNER JOIN @billGroupMemberMoves bgmt
      ON bgmt.id_billgroup_old = bgm.id_billgroup AND
            bgmt.id_acc = bgm.id_acc
   WHERE bgmt.oldStatus = 'O' AND
               (bgmt.newStatus = 'O' OR bgmt.newStatus IS NULL)

    /* Insert updated account(s) into t_billgroup_member */
    INSERT INTO t_billgroup_member (id_billgroup, id_acc, id_materialization, id_root_billgroup)
    SELECT bgmt.id_billgroup_new, bgmt.id_acc, bgmt.id_materialization_new, 
                dbo.GetBillingGroupAncestor(bgmt.id_billgroup_new)
    FROM @billGroupMemberMoves bgmt
    WHERE bgmt.oldStatus = 'O' AND
                (bgmt.newStatus = 'O' OR bgmt.newStatus IS NULL)

   /* Insert new history for account */
   INSERT INTO t_billgroup_member_history (id_billgroup, 
                                                                      id_acc, 
                                                                      id_materialization,
                                                                      tx_status,
                                                                      tt_start,
                                                                      tt_end)
   SELECT bgmt.id_billgroup_new, 
               bgmt.id_acc, 
               bgmt.id_materialization_new,
               'Succeeded',
               @dt_end,
               dbo.MTMaxDate()
   FROM @billGroupMemberMoves bgmt
   WHERE bgmt.oldStatus = 'O' AND
               (bgmt.newStatus = 'O' OR bgmt.newStatus IS NULL)

  /*
     Doing (1a) from the above algorithm
  */
   -- Delete old billgroup if it doesn't have any accounts
   IF EXISTS (SELECT 1 
                FROM dbo.sysobjects
                WHERE id = OBJECT_ID(N't_deleted_billgroups') AND
                                   OBJECTPROPERTY(id, N'IsUserTable') = 1) 
   BEGIN
      DROP TABLE t_deleted_billgroups
   END
   CREATE TABLE t_deleted_billgroups (id_billgroup INT NOT NULL)
 
   INSERT INTO t_deleted_billgroups
   SELECT id_billgroup
   FROM t_billgroup bg
   INNER JOIN @billGroupMemberMoves bgmoves
      ON bgmoves.id_billgroup_old = bg.id_billgroup AND
            bgmoves.id_billgroup_old NOT IN (SELECT id_billgroup
                                                                    FROM t_billgroup_member) 
   WHERE bgmoves.oldStatus = 'O' AND
                (bgmoves.newStatus = 'O' OR bgmoves.newStatus IS NULL)

   EXEC DeleteBillGroupData 't_deleted_billgroups' 
   DROP TABLE t_deleted_billgroups
 
  /* Doing (2) from the above algorithm. 
       Insert rows into t_billgroup_member_history for account moves into and out of 'Soft Closed' or
       'Hard Closed' billing groups. These are not 'history' rows because
       no change is happening to the account. The tt_start and tt_end times on these rows
       don't matter. They are filtered based on tx_status = 'Failed'
   */
    INSERT INTO t_billgroup_member_history (id_billgroup, 
                                                                        id_acc, 
                                                                        id_materialization,
                                                                        tx_status,
                                                                        tt_start,
                                                                        tt_end,
                                                                        tx_failure_reason)
   SELECT NULL, 
               bgmt.id_acc, 
               bgmt.id_materialization_new,
               'Failed',
               @dt_end,
               @dt_end,
               'Attempting to move this account from billing group [' + 
               bgmt.billgroup_name_old +
                ']  to billing group [' +
               bgmt.billgroup_name_new  + 
               '] when one (or both) billing group is not in an Open state.'
   FROM @billGroupMemberMoves bgmt
   WHERE bgmt.oldStatus != 'O' OR
               (bgmt.newStatus != 'O' AND bgmt.newStatus IS NOT NULL)

    /* Clear billGroupMemberMoves */
   DELETE  @billGroupMemberMoves

   DECLARE @billUnassignedAccountMoves TABLE (id_materialization INT NOT NULL, 
                                                                                id_acc INT NOT NULL,
                                                                                id_billgroup INT NOT NULL,
                                                                                billgroup_name NVARCHAR(50) NOT NULL,
                                                                                status VARCHAR(1))

   /* Doing (3) from the above algorithm */
   INSERT @billUnassignedAccountMoves
   SELECT bgmt.id_materialization, 
               bgmt.id_acc, 
               bg.id_billgroup, 
               bg.tx_name,
               bgs.status
   FROM t_billgroup_member_tmp bgmt
   INNER JOIN t_billgroup_tmp bgt 
      ON bgt.tx_name = bgmt.tx_name AND
            bgt.id_materialization = bgmt.id_materialization
   INNER JOIN t_billgroup bg 
      ON bg.tx_name = bgt.tx_name
   LEFT OUTER JOIN vw_all_billing_groups_status bgs 
      ON bgs.id_billgroup = bg.id_billgroup 
   WHERE 
       bgmt.id_acc NOT IN (SELECT id_acc 
                                         FROM t_billgroup_member 
                                         WHERE id_billgroup IN (SELECT id_billgroup 
                                                                              FROM t_billgroup 
                                                                              WHERE id_usage_interval = @id_usage_interval)) AND
       bgmt.id_materialization = @id_materialization AND  
       bg.id_billgroup IN (SELECT id_billgroup 
                                     FROM t_billgroup 
                                     WHERE id_usage_interval = @id_usage_interval) 
 
    /* Insert updated account(s) into t_billgroup_member */
    INSERT INTO t_billgroup_member (id_billgroup, id_acc, id_materialization, id_root_billgroup)
    SELECT buam.id_billgroup, buam.id_acc, buam.id_materialization,
                dbo.GetBillingGroupAncestor(buam.id_billgroup)
    FROM @billUnassignedAccountMoves buam
    WHERE buam.status = 'O' OR buam.status IS NULL
    
   /* Insert new history for account */
   INSERT INTO t_billgroup_member_history (id_billgroup, 
                                                                      id_acc, 
                                                                      id_materialization,
                                                                      tx_status,
                                                                      tt_start,
                                                                      tt_end)
   SELECT buam.id_billgroup, 
               buam.id_acc, 
               buam.id_materialization,
               'Succeeded',
               @dt_end,
               dbo.MTMaxDate()
   FROM @billUnassignedAccountMoves buam
   WHERE buam.status = 'O' OR buam.status IS NULL
 
    /* Doing (4) from the above algorithm.
        Insert rows into t_billgroup_member_history. These are not 'history' rows because
        no change is happening to the account. The tt_start and tt_end times on these rows
        don't matter. They are filtered based on tx_status = 'Failed'
   */
    INSERT INTO t_billgroup_member_history (id_billgroup, 
                                                                        id_acc, 
                                                                        id_materialization,
                                                                        tx_status,
                                                                        tt_start,
                                                                        tt_end,
                                                                        tx_failure_reason)
   SELECT NULL, 
               buam.id_acc, 
               buam.id_materialization,
               'Failed',
               @dt_end,
               @dt_end,
                'Attempting to assign this account to the billing group [' + 
               buam.billgroup_name +
                ']  when the  billing group is not in an Open state.'
   FROM @billUnassignedAccountMoves buam
   WHERE status != 'O' AND status IS NOT NULL
 
   /* Check that each billing group in t_billgroup has atleast one account  */
   IF EXISTS (SELECT bg.id_billgroup
                   FROM t_billgroup bg
                   WHERE bg.id_billgroup NOT IN (SELECT id_billgroup 
                                                                     FROM t_billgroup_member bgm)
																	 and id_usage_interval = @id_usage_interval)
   BEGIN
      SET @status = -2
      ROLLBACK
      RETURN 
   END

   /* Clear @billUnassignedAccountMoves */
   DELETE  @billUnassignedAccountMoves

   /* Copy over billing group constraints */
  EXEC ResetBillingGroupConstraints @id_usage_interval, @status OUTPUT
  IF (@status != 0) 
       BEGIN
          SET @status = -3
          ROLLBACK
          RETURN 
       END
   /* Reset status */
   SET @status = -1

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
