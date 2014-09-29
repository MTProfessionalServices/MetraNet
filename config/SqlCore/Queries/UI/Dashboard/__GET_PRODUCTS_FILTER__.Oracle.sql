SELECT DISTINCT
	pit.id_pi,
	bp.nm_name
FROM t_pi_template AS pit
INNER JOIN t_acc_usage AS au ON pit.id_template = au.id_pi_template
INNER JOIN t_base_props AS bp ON pit.id_pi = bp.id_prop
ORDER BY pit.id_pi