SELECT 
rer.id_instance,
rei.id_arg_billgroup id_billgroup,
rei.id_arg_interval id_interval,
re.tx_display_name as Name,
rer.dt_start as StartDate,
rer.dt_end as EndDate,
rer.tx_status as Status
FROM t_recevent_run rer
join t_recevent_inst rei on   rei.id_instance = rer.id_instance
join t_recevent re on re.id_event = rei.id_event
where rer.tx_status = 'InProgress'
and rer.dt_start > DATEADD(month, -1, getutcdate())
order by EndDate desc