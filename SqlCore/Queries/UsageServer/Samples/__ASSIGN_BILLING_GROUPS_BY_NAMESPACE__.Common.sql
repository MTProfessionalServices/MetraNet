/*
===========================================================
  Assign billing groups by Namespace
===========================================================
*/
/* assigns constraint groups (and the accounts contained in them) to billing groups */
INSERT INTO t_billgroup_member_tmp (id_materialization, id_acc, tx_name)
SELECT 
	%%ID_MATERIALIZATION%%, 
	cg.id_acc,
	ns.nm_space
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
JOIN t_namespace ns on amap.nm_space = ns.nm_space and ns.tx_typ_space = 'system_mps' and ns.nm_method = 'Partition'
UNION ALL
SELECT 
  %%ID_MATERIALIZATION%%, 
  cg.id_acc,
  lower(t_account_mapper.nm_login)
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
JOIN t_account_type on t_account.id_type = t_account_type.id_type and t_account_type.name = 'Partition'
JOIN t_account_mapper on cg.id_acc = t_account_mapper.id_acc  and t_account_mapper.nm_space = 'mt'
UNION ALL
SELECT 
	%%ID_MATERIALIZATION%%, 
	cg.id_acc,
	N'Default'
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
JOIN t_namespace ns on amap.nm_space = ns.nm_space and ns.tx_typ_space = 'system_mps' and (ns.nm_method IS NULL OR ns.nm_method !=  'Partition')
WHERE amap.id_acc NOT IN
(
  SELECT 
    t_account.id_acc
  FROM t_account
  INNER JOIN t_account_type on t_account.id_type = t_account_type.id_type and t_account_type.name = 'Partition'
  INNER JOIN t_account_mapper on t_account.id_acc = t_account_mapper.id_acc  and t_account_mapper.nm_space = 'mt'
)

