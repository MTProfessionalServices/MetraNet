
/* ===========================================================
This is executed after the adapters have created billing group constraints in
t_billgroup_constraint_tmp.

1) Fill in missing payers 
If any of the accounts in t_billgroup_source_acc do not exist
in t_billgroup_constraint_tmp after the adapters have created
their constraint groups, then create one group per account for
the remaining accounts.

2) Validate that the id_group in t_billgroup_constraint_tmp is correctly named 
ie. it must be any one of the account IDs in the constraint group

3) Prunes (must be regular) and coalesces constraint groups. 
If constraint groups intersect, they will be coalesced into 
larger groups containing a union of the intersecting groups. 
Worst case, all groups will coalesce into one supergroup 
representing every payer in the interval. 
By the end of this process, there will be one row for 
every payer and every payer will belong to exactly one constraint group.

Returns:
-1 if an unknown error has occurred
-2 if the accounts in t_billgroup_constraint_tmp are not paying accounts
-3 if the id_group is not named as one of the accounts in the group
-4 if there are duplicate id_acc for the given @id_materialization
============================================================== */
CREATE OR REPLACE
PROCEDURE CompleteBillGroupConstraints
(
   p_id_materialization INT,
   status out INT
)
AS
  v_id_usage_interval int;
  cnt int := 0;
BEGIN 

  /* initialize @status to failure (-1) */
  status := -1;
    
  /* Store the id_usage_interval */
  SELECT bm.id_usage_interval into v_id_usage_interval
  FROM t_billgroup_materialization bm
  WHERE id_materialization = p_id_materialization;

   /* Validate that the accounts in t_billgroup_constraint_tmp are paying accounts */
  cnt := 0;
SELECT COUNT (bctmp.id_acc) into cnt
  FROM t_billgroup_constraint_tmp bctmp
  WHERE id_usage_interval = v_id_usage_interval AND not exists (SELECT 1
  FROM t_acc_usage_interval aui
  INNER JOIN t_account_mapper amap ON amap.id_acc = aui.id_acc
  INNER JOIN t_namespace nmspace ON nmspace.nm_space = amap.nm_space
  WHERE  nmspace.tx_typ_space = 'system_mps' 
  and aui.id_acc = bctmp.id_acc
  and aui.id_usage_interval = v_id_usage_interval);  

IF (cnt > 0) then 
    status := -2;
    ROLLBACK;
    RETURN; 
  END if;

  /* Validate that the id_group in t_billgroup_constraint_tmp is correctly named 
     ie. it must be any one of the account IDs in the constraint group */
  cnt := 0;
  SELECT count(1) into cnt from dual
  where exists (
    select 1
    FROM t_billgroup_constraint_tmp t1
    WHERE t1.id_group NOT IN (
      SELECT id_acc
      FROM t_billgroup_constraint_tmp
      WHERE id_group = t1.id_group)
    );

  IF (cnt > 0) then
    status := -3;
    ROLLBACK;
    RETURN;
  END if;

  /* coalesces constraint groups into a set of unique, disjoint supergroups  */
  for bgcur in 
  (select distinct id_group from t_billgroup_constraint_tmp
	where id_acc in
		(
		select id_acc from
		t_billgroup_constraint_tmp
		group by id_acc,id_usage_interval
		having count(id_group) > 1
		)
	) loop
  
    /* check if group still exists  */
    cnt := 0;
    SELECT count(1) into cnt FROM t_billgroup_constraint_tmp 
      where id_group = bgcur.id_group;
      
    
    IF cnt > 0 then  
      /* the group still exists */
      
      /* figure out which other groups reference accounts from this group */
      delete tmp_otherBillGroups;
      INSERT INTO tmp_otherBillGroups
      SELECT distinct c2.id_group
      FROM t_billgroup_constraint_tmp c1
      INNER JOIN t_billgroup_constraint_tmp c2 
          ON c2.id_acc = c1.id_acc 
          AND c2.id_usage_interval = c1.id_usage_interval
      WHERE c1.id_group = bgcur.id_group AND c2.id_group <> bgcur.id_group;
        
      /* adds the additional groups' members to the group we are currently processing */
      INSERT INTO t_billgroup_constraint_tmp (
        id_usage_interval, id_group, id_acc)
      SELECT DISTINCT
        v_id_usage_interval, bgcur.id_group, id_acc
      FROM t_billgroup_constraint_tmp 
      WHERE id_group IN (SELECT id_group FROM tmp_otherbillGroups) 
        AND id_acc NOT IN (
          SELECT id_acc FROM t_billgroup_constraint_tmp 
          WHERE id_group = bgcur.id_group 
            AND id_usage_interval = v_id_usage_interval
            ) 
        AND id_usage_interval = v_id_usage_interval;
  
      /* deletes the additional groups now that we've copied their members */
      DELETE FROM t_billgroup_constraint_tmp 
      WHERE id_group IN (SELECT id_group FROM tmp_otherbillGroups);
  
    end if;
  END loop;

  /* Fill in missing payers.
  Adds in the remaining constraint groups of single payers
  that don't already exist in any other constraint groups 
  */
  INSERT INTO t_billgroup_constraint_tmp(id_usage_interval, id_group, id_acc)
  SELECT v_id_usage_interval, id_acc, id_acc
  FROM t_billgroup_source_acc
  WHERE id_materialization = p_id_materialization 
    AND id_acc NOT IN (
      SELECT id_acc FROM t_billgroup_constraint_tmp 
      WHERE id_usage_interval = v_id_usage_interval);

  /* Check for duplicate accounts */
  cnt := 0;
  select count(1) into cnt from dual
  where exists (
    select 1
    from t_billgroup_constraint_tmp
    where id_usage_interval = v_id_usage_interval
    group by id_acc having count(id_acc) > 1
    );
  
   if (cnt > 0) then
     status := -4;
     ROLLBACK;
     RETURN; 
   END if;
  
  status := 0;
  commit;
  
end CompleteBillGroupConstraints;
 