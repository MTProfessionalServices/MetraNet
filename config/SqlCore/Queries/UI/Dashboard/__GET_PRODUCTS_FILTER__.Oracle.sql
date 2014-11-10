SELECT DISTINCT
	acc.id_pi_template,
	bp.nm_name
FROM t_acc_usage acc
INNER JOIN t_base_props bp ON acc.id_pi_template = bp.id_prop
ORDER BY acc.id_pi_template