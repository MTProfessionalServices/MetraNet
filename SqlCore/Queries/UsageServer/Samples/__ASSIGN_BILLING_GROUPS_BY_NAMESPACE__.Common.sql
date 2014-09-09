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
