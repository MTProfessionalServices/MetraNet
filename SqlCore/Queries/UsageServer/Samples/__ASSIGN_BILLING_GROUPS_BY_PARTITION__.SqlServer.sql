/*
===========================================================
  Assign billing groups by Partition
===========================================================
*/
/* assigns constraint groups (and the accounts contained in them) to billing groups */
INSERT INTO t_billgroup_member_tmp (id_materialization, id_acc, tx_name, id_partition)
SELECT 
	%%ID_MATERIALIZATION%%, 
	cg.id_acc,
	tamap.nm_login + N' Default',
  tamap.id_acc
FROM t_billgroup_constraint_tmp cg
JOIN
(
	SELECT 
		id_group,
		MAX(id_acc) id_acc
	FROM t_billgroup_constraint_tmp
	GROUP BY id_group
) singleacc ON singleacc.id_group = cg.id_group
JOIN t_account_mapper amap on cg.id_acc = amap.id_acc
JOIN t_namespace ns on amap.nm_space = ns.nm_space and lower(ns.tx_typ_space) = 'system_mps' and lower(ns.nm_method) = 'partition'
JOIN t_account_mapper tamap on lower(tamap.nm_login) = lower(ns.nm_space) where lower(tamap.nm_space) = 'mt'
UNION ALL
SELECT 
  %%ID_MATERIALIZATION%%, 
  cg.id_acc,
  t_account_mapper.nm_login + N' Default',
  t_account_mapper.id_acc
FROM t_billgroup_constraint_tmp cg
JOIN
(
  SELECT 
    id_group,
    MAX(id_acc) id_acc
  FROM t_billgroup_constraint_tmp
  GROUP BY id_group
) singleacc ON singleacc.id_group = cg.id_group
JOIN t_account on cg.id_acc = t_account.id_acc
JOIN t_account_type on t_account.id_type = t_account_type.id_type and lower(t_account_type.name) = 'partition'
JOIN t_account_mapper on cg.id_acc = t_account_mapper.id_acc  and lower(t_account_mapper.nm_space) = 'mt'
UNION ALL
SELECT 
	%%ID_MATERIALIZATION%%, 
	cg.id_acc,
	N'Default',
  Null
FROM t_billgroup_constraint_tmp cg
JOIN
(
	SELECT 
		id_group,
		MAX(id_acc) id_acc
	FROM t_billgroup_constraint_tmp
	GROUP BY id_group
) singleacc ON singleacc.id_group = cg.id_group
JOIN t_account_mapper amap on cg.id_acc = amap.id_acc
JOIN t_namespace ns on amap.nm_space = ns.nm_space and lower(ns.tx_typ_space) = 'system_mps' and (ns.nm_method IS NULL OR lower(ns.nm_method) !=  'partition')
WHERE amap.id_acc NOT IN
(
  SELECT 
    t_account.id_acc
  FROM t_account
  INNER JOIN t_account_type on t_account.id_type = t_account_type.id_type and t_account_type.name = 'Partition'
  INNER JOIN t_account_mapper on t_account.id_acc = t_account_mapper.id_acc  and t_account_mapper.nm_space = 'mt'
)
