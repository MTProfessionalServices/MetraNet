SELECT 
r.tx_name 
,ri.id_instance 
,ri.tx_status 
,rr.id_run 
,rr.tx_status 
,rr.dt_start 
,rr.dt_end 
,rr.tx_detail 
FROM t_recevent r 
join t_recevent_inst ri ON ri.id_event = r.id_event 
left join t_recevent_run rr ON rr.id_instance = ri.id_instance 
left join t_usage_interval ui ON ui.id_interval = ri.id_arg_interval 
WHERE ri.tx_status = 'Failed' 
ORDER BY ri.id_instance DESC