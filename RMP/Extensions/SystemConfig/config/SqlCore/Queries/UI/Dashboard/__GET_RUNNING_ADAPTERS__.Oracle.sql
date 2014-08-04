SELECT 
rer.id_instance,
rei.id_arg_billgroup AS id_billgroup,
rei.id_arg_interval AS id_interval,
re.tx_display_name AS Name,
rer.dt_start AS StartDate,
rer.dt_end AS EndDate,
rer.tx_status AS Status
FROM t_recevent_run rer
JOIN t_recevent_inst rei ON rei.id_instance = rer.id_instance
JOIN t_recevent re ON re.id_event = rei.id_event
WHERE rer.tx_status = 'InProgress'
AND rer.dt_start > add_months(getutcdate(), -1)
ORDER BY EndDate DESC