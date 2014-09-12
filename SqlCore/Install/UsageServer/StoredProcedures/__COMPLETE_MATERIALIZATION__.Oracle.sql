
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
CREATE OR REPLACE
PROCEDURE CompleteMaterialization
(
  p_id_materialization INT,
  p_dt_end date,
  status out INT
)
AS

  v_id_usage_interval int;
  cnt int;  
  p_maxdate date;
  v_table_name varchar(30);
  v_sampling_ratio int;
BEGIN
   /* initialize @status to failure (-1) */
   status := -1;
   v_sampling_ratio := 20;
  
   /* ESR-2814 analyze table */  
   v_table_name := 't_billgroup_tmp';   
   mt_sys_analyze_table ( v_table_name ,v_sampling_ratio);

   /* ESR-2814 analyze table */  
   v_table_name := 't_billgroup_member_tmp';   
   mt_sys_analyze_table ( v_table_name ,v_sampling_ratio);

   /* copy data from t_billgroup_tmp to t_billgroup */
   INSERT INTO t_billgroup (id_billgroup, tx_name, tx_description, id_usage_interval, id_parent_billgroup, tx_type, id_partition)
   SELECT bgt.id_billgroup, bgt.tx_name, bgt.tx_description, bgm.id_usage_interval, bgm.id_parent_billgroup, bgm.tx_type, bgt.id_partition
   FROM t_billgroup_tmp bgt    
   INNER JOIN t_billgroup_materialization bgm 
    ON bgm.id_materialization = bgt.id_materialization
   WHERE bgm.id_materialization = p_id_materialization;

  /* copy data from t_billgroup_member_tmp to t_billgroup_member */
  INSERT INTO t_billgroup_member (id_billgroup, id_acc, id_materialization, id_root_billgroup)
  SELECT bgt.id_billgroup, 
        bgmt.id_acc, 
        p_id_materialization, 
        dbo.GetBillingGroupAncestor(bgt.id_billgroup)
  FROM t_billgroup_member_tmp bgmt
  INNER JOIN t_billgroup_tmp bgt 
     ON bgt.tx_name = bgmt.tx_name  
  WHERE bgmt.id_materialization =  p_id_materialization
    AND bgt.id_materialization = p_id_materialization;
   
	select dbo.MTMaxDate() into p_maxdate from dual;
/* update t_billgroup_member_history */
  INSERT INTO t_billgroup_member_history (id_billgroup, 
      id_acc, 
      id_materialization,
      tx_status,
      tt_start,
      tt_end)
  SELECT bgt.id_billgroup, 
              bgmt.id_acc, 
              p_id_materialization,
              'Succeeded',
              p_dt_end,
              p_maxdate
  FROM t_billgroup_member_tmp bgmt
  INNER JOIN t_billgroup_tmp bgt 
     ON bgt.tx_name = bgmt.tx_name  
  WHERE bgmt.id_materialization =  p_id_materialization
    AND bgt.id_materialization = p_id_materialization;

  /* store the id_usage_interval */
  SELECT max(bgm.id_usage_interval) into v_id_usage_interval
  FROM t_billgroup_materialization bgm
  WHERE bgm.id_materialization = p_id_materialization;
  
  /* Copy over billing group constraints */
  ResetBillingGroupConstraints(v_id_usage_interval, status);

  IF (status != 0) then
    status := -2;
    ROLLBACK;
    RETURN;
  END if;
  
   /* Reset status */
  status := -1;

  SELECT count(bg.id_billgroup) into cnt
  FROM t_billgroup bg
  WHERE bg.id_billgroup NOT IN (
    SELECT id_billgroup FROM t_billgroup_member bgm)
  and id_usage_interval = v_id_usage_interval;

   /* Check that each billing group in t_billgroup has atleast one account  */
  if cnt > 0 then
    status := -3;
    ROLLBACK;
    RETURN;
   END if;

   /* Delete temporary data and update t_billgroup_materialization */
   CleanupMaterialization(
        p_id_materialization, 
        p_dt_end, 
        'Succeeded', 
        NULL, 
        status);

  IF (status != 0)  then
    status := -4;
    ROLLBACK;
    RETURN;
   END if;

   /* set @status to success */
   status := 0;

   COMMIT;

end CompleteMaterialization;
