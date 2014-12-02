SELECT 
r.tx_name AdapterName
,ri.id_instance InstanceID
,rr.id_run RunID
,ri.id_arg_interval IntervalID
,rr.tx_detail ErrorDetail
FROM t_recevent r 
join t_recevent_inst ri ON ri.id_event = r.id_event 
left join t_recevent_run rr ON rr.id_instance = ri.id_instance 
left join t_usage_interval ui ON ui.id_interval = ri.id_arg_interval 
WHERE ri.tx_status = 'Failed' 
ORDER BY ri.id_instance DESC