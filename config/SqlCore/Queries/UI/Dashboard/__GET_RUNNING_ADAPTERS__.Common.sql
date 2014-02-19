SELECT 
re.tx_display_name as Name,
rer.dt_start as Start,
rer.dt_end as EndDate,
rer.tx_status as Status
FROM t_recevent_run rer
join t_recevent_inst rei on   rei.id_instance = rer.id_instance
join t_recevent re on re.id_event = rei.id_event
where rer.tx_status = 'InProgress'
and rer.dt_start > DATEADD(month, -1, getdate())
order by EndDate desc