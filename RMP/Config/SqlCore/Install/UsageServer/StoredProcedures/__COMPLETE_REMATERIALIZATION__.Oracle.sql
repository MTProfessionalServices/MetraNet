

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
CREATE OR REPLACE
PROCEDURE CompleteReMaterialization
(
  p_id_materialization INT,
  p_dt_end date,
  status out INT
)
AS

  cnt int;
  v_id_usage_interval INT;
  v_table_name varchar(30);
  v_sampling_ratio number;

BEGIN
 
  /* initialize @status to failure (-1) */
  status := -1;
  v_sampling_ratio := 20;

  /* Get the id_usage_interval for the given p_id_materialization */
  SELECT id_usage_interval  into v_id_usage_interval 
  FROM t_billgroup_materialization bgm
  WHERE bgm.id_materialization = p_id_materialization;

  /* copy billing groups from t_billgroup_tmp to t_billgroup
    only if they don't exist in t_billgroup for the interval associated with
    this p_id_materialization
    */
  INSERT INTO t_billgroup (id_billgroup, tx_name, tx_description, 
    id_usage_interval, id_parent_billgroup, tx_type, id_partition)
  SELECT bgt.id_billgroup, bgt.tx_name, bgt.tx_description,
    bgm.id_usage_interval, bgm.id_parent_billgroup, bgm.tx_type, bgt.id_partition
  FROM t_billgroup_tmp bgt 
  INNER JOIN t_billgroup_materialization bgm 
         ON bgm.id_materialization = bgt.id_materialization   
  WHERE bgt.id_materialization = p_id_materialization 
    AND bgt.tx_name NOT IN (
      SELECT tx_name 
      FROM t_billgroup 
      WHERE id_usage_interval = v_id_usage_interval);
      
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
 
   /* ESR-2814 analyze table */ 
   v_table_name := 't_billgroup_member_tmp';   
   mt_sys_analyze_table ( v_table_name ,v_sampling_ratio);

  /* Doing (1) from the above algorithm
  In t_billgroup_member, the id_acc will be unique amongst the billgroups for
  a given interval
  */
  INSERT into tmp_billGroupMemberMoves
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
    ON bg.id_billgroup = bgmem.id_billgroup
    AND bg.tx_name != bgmt.tx_name
  INNER JOIN t_billgroup_tmp bgt 
    ON bgt.tx_name = bgmt.tx_name
    AND bgt.id_materialization = bgmt.id_materialization
  INNER JOIN t_billgroup bg1
    ON bg1.tx_name = bgmt.tx_name
  LEFT OUTER JOIN vw_all_billing_groups_status bgsNew 
    ON bgsNew.id_billgroup = bg1.id_billgroup
  LEFT OUTER JOIN vw_all_billing_groups_status bgsOld
    ON bgsOld.id_billgroup = bg.id_billgroup
  WHERE bgmt.id_materialization =  p_id_materialization 
    AND bg.id_billgroup IN (
        SELECT id_billgroup 
        FROM t_billgroup 
        WHERE id_usage_interval = v_id_usage_interval) 
    AND bg1.id_billgroup IN (
        SELECT id_billgroup 
        FROM t_billgroup 
        WHERE id_usage_interval = v_id_usage_interval);

  /* Update history for account */
  UPDATE t_billgroup_member_history bgmh
  SET tt_end = p_dt_end
  where exists (
    select 1 
    FROM tmp_billGroupMemberMoves bgmt
    where bgmt.id_acc = bgmh.id_acc
    AND bgmt.id_billgroup_old = bgmh.id_billgroup 
    AND bgmt.id_materialization_old = bgmh.id_materialization
    and bgmt.oldStatus = 'O' 
    AND (bgmt.newStatus = 'O' OR bgmt.newStatus IS NULL)
    );

  /* Delete account(s) from t_billgroup_member */
  DELETE FROM t_billgroup_member bgm
  where exists (
    select 1 
    from tmp_billGroupMemberMoves bgmt
    where bgmt.id_billgroup_old = bgm.id_billgroup
      AND bgmt.id_acc = bgm.id_acc
      and bgmt.oldStatus = 'O' 
      AND (bgmt.newStatus = 'O' OR bgmt.newStatus IS NULL)
    );

  /* Insert updated account(s) into t_billgroup_member */
  INSERT INTO t_billgroup_member (id_billgroup, id_acc, id_materialization, 
    id_root_billgroup)
  SELECT bgmt.id_billgroup_new, bgmt.id_acc, bgmt.id_materialization_new, 
    dbo.GetBillingGroupAncestor(bgmt.id_billgroup_new)
  FROM tmp_billGroupMemberMoves bgmt
  WHERE bgmt.oldStatus = 'O'
    AND (bgmt.newStatus = 'O' OR bgmt.newStatus IS NULL);

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
    p_dt_end,
    dbo.MTMaxDate()
  FROM tmp_billGroupMemberMoves bgmt
  WHERE bgmt.oldStatus = 'O' 
    AND (bgmt.newStatus = 'O' OR bgmt.newStatus IS NULL);

  /*
    Doing (1a) from the above algorithm
  */

  /* Delete old billgroup if it doesn't have any accounts */
  INSERT INTO tmp_deleted_billgroups
  SELECT id_billgroup
  FROM t_billgroup bg
  INNER JOIN tmp_billGroupMemberMoves bgmoves
    ON bgmoves.id_billgroup_old = bg.id_billgroup 
    AND bgmoves.id_billgroup_old NOT IN (
      SELECT id_billgroup
      FROM t_billgroup_member) 
  WHERE bgmoves.oldStatus = 'O' 
    AND (bgmoves.newStatus = 'O' OR bgmoves.newStatus IS NULL);
  
  DeleteBillGroupData('tmp_deleted_billgroups');

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
    p_dt_end,
    p_dt_end,
    'Attempting to move this account from billing group [' 
      || bgmt.billgroup_name_old 
      || ']  to billing group ['
      || bgmt.billgroup_name_new 
      || '] when one (or both) billing group is not in an Open state.'
      as reason
  FROM tmp_billGroupMemberMoves bgmt
  WHERE bgmt.oldStatus != 'O' 
    OR (bgmt.newStatus != 'O' AND bgmt.newStatus IS NOT NULL);

  /* Clear billGroupMemberMoves */
  DELETE  tmp_billGroupMemberMoves;

  /* Doing (3) from the above algorithm */
  INSERT into tmp_billUnassignedAccountMoves
  SELECT bgmt.id_materialization, 
    bgmt.id_acc, 
    bg.id_billgroup, 
    bg.tx_name,
    bgs.status
  FROM t_billgroup_member_tmp bgmt
  INNER JOIN t_billgroup_tmp bgt 
    ON bgt.tx_name = bgmt.tx_name
    AND bgt.id_materialization = bgmt.id_materialization
  INNER JOIN t_billgroup bg 
    ON bg.tx_name = bgt.tx_name
  LEFT OUTER JOIN vw_all_billing_groups_status bgs 
    ON bgs.id_billgroup = bg.id_billgroup 
  WHERE bgmt.id_acc NOT IN (
    SELECT id_acc
    FROM t_billgroup_member 
    WHERE id_billgroup IN (
      SELECT id_billgroup 
      FROM t_billgroup 
      WHERE id_usage_interval = v_id_usage_interval
      )
    ) 
    AND bgmt.id_materialization = p_id_materialization
    AND bg.id_billgroup IN (
      SELECT id_billgroup 
      FROM t_billgroup 
      WHERE id_usage_interval = v_id_usage_interval
      ); 
  
  /* Insert updated account(s) into t_billgroup_member */
  INSERT INTO t_billgroup_member (id_billgroup, id_acc, id_materialization, 
    id_root_billgroup)
  SELECT buam.id_billgroup, buam.id_acc, buam.id_materialization,
    dbo.GetBillingGroupAncestor(buam.id_billgroup)
  FROM tmp_billUnassignedAccountMoves buam
  WHERE buam.status = 'O' OR buam.status IS NULL;
  
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
    p_dt_end,
    dbo.MTMaxDate()
  FROM tmp_billUnassignedAccountMoves buam
  WHERE buam.status = 'O' OR buam.status IS NULL;
  
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
    p_dt_end,
    p_dt_end,
    'Attempting to assign this account to the billing group ['
    || buam.billgroup_name
    || ']  when the  billing group is not in an Open state.'
      as reason
  FROM tmp_billUnassignedAccountMoves buam
  WHERE status != 'O' AND status IS NOT NULL;

  /* Check that each billing group in t_billgroup has atleast one account  */
  SELECT count(bg.id_billgroup) into cnt
  FROM t_billgroup bg
  WHERE bg.id_billgroup NOT IN (
    SELECT id_billgroup 
    FROM t_billgroup_member bgm);
    
  IF cnt > 0 then 
    status := -2;
    ROLLBACK;
    RETURN; 
  END if;

  /* Clear @billUnassignedAccountMoves */
  DELETE  tmp_billUnassignedAccountMoves;

  /* Copy over billing group constraints */
  ResetBillingGroupConstraints(v_id_usage_interval, status);
  
  IF (status != 0) then
    status := -3;
    RollbacK;
    RETURN;
  END if;

  /* Reset status */
  status := -1;

  /* Delete temporary data and update t_billgroup_materialization */
  CleanupMaterialization(p_id_materialization, 
    p_dt_end, 
    'Succeeded', 
    NULL, 
    status);
  
  IF (status != 0) then
    status := -4;
    ROLLBACk;
    RETURN;
  END if;
  
  /* set status to success */
  status := 0;
  
  COMMIt;

END CompleteReMaterialization;
	