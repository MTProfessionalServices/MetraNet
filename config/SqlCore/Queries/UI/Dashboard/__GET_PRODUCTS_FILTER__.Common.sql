SELECT DISTINCT
	acc.id_pi_template,
	bp.nm_name
FROM t_acc_usage AS acc
INNER JOIN t_base_props AS bp ON acc.id_pi_template = bp.id_prop
ORDER BY acc.id_pi_template