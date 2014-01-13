     
        select evt.id_event as EventId, evt.tx_display_name "Display Name", evt.tx_name "Name", 
				evt.tx_desc Description, max(evi.dt_arg_end) "InstanceLastArgEndDate"
				from t_recevent evt
				left join t_recevent_inst evi on evt.id_event=evi.id_event where %%%UPPER%%%(evt.tx_type) = 'SCHEDULED'
				AND   evt.dt_activated <= %%%SYSTEMDATE%%% AND (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) 
				group by evt.id_event, evt.tx_display_name, evt.tx_name, evt.tx_desc order by evt.tx_display_name  
 			