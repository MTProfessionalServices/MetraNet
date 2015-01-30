
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
CREATE OR REPLACE
PROCEDURE CompleteChildGroupCreation
(
  p_id_materialization INT,
  p_dt_end DATE,
  status out INT
)
AS
  v_id_parent_billgroup INT;
  cnt int;
  v_id_partition INT;
BEGIN
  /* initialize @status to failure (-1) */
  status := -1;
  
  SELECT max(id_parent_billgroup), count(id_parent_billgroup) 
    into v_id_parent_billgroup, cnt
  FROM t_billgroup_materialization
  WHERE id_materialization = p_id_materialization;
  
  /* Error if there is no id_parent_billgroup is NULL */
  IF cnt != 1 then
    status := -2;
    RETURN;
  END if;
  
  /* delete child group accounts for parent billing group 
    from t_billgroup_member
    */
  DELETE  t_billgroup_member bgm
  where exists (
    select 1 
    from t_billgroup_member_tmp bgmt
  WHERE bgmt.id_acc = bgm.id_acc
    and bgmt.id_materialization = p_id_materialization 
    AND bgm.id_billgroup = v_id_parent_billgroup);

  /* update t_billgroup_member_history to reflect the deletion */
  UPDATE t_billgroup_member_history bgmh
    SET tt_end = p_dt_end
  where exists (
    select 1 
    from t_billgroup_member_tmp bgmt
    where bgmt.id_acc = bgmh.id_acc
      and bgmt.id_materialization = p_id_materialization 
      and bgmh.id_billgroup = v_id_parent_billgroup);
  
   -- get id_partition of the parent bill group
   SELECT id_partition
   INTO v_id_partition
   FROM t_billgroup bg 
   WHERE id_billgroup = v_id_parent_billgroup;
  
  /* insert child billing group data into t_billgroup from t_billgroup_tmp */
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
    v_id_partition
  FROM t_billgroup_tmp bgt    
  INNER JOIN t_billgroup_materialization bgm 
     ON bgm.id_materialization = bgt.id_materialization
  WHERE bgm.id_materialization = p_id_materialization;

  /* insert child billing group data into t_billgroup_member */
  INSERT INTO t_billgroup_member (id_billgroup, id_acc, id_materialization, 
    id_root_billgroup)
  SELECT bgt.id_billgroup, bgmt.id_acc, p_id_materialization, 
    dbo.GetBillingGroupAncestor(bgt.id_billgroup) 
  FROM t_billgroup_member_tmp bgmt
  INNER JOIN t_billgroup_tmp bgt 
   ON bgt.tx_name = bgmt.tx_name  
  WHERE bgmt.id_materialization =  p_id_materialization
    and bgt.id_materialization = p_id_materialization;

  /* update t_billgroup_member_history to reflect the addition */
  INSERT INTO t_billgroup_member_history (
    id_billgroup, 
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
    dbo.MTMaxDate()
  FROM t_billgroup_member_tmp bgmt
  INNER JOIN t_billgroup_tmp bgt 
    ON bgt.tx_name = bgmt.tx_name  
  WHERE bgmt.id_materialization =  p_id_materialization 
    and bgt.id_materialization = p_id_materialization;
  
  /* set @status to success */
  status := 0; 

END CompleteChildGroupCreation;
