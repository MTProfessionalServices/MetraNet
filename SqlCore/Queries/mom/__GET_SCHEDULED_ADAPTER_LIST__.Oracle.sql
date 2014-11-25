     
        select evt.id_event EventId, 
		        nvl((select tx_name from t_recevent_localize	where id_lang_code = %%ID_LANG_CODE%% and id_local = evt.id_event),  evt.tx_display_name) DisplayName,
				nvl((select tx_desc from t_recevent_localize	where id_lang_code = %%ID_LANG_CODE%% and id_local = evt.id_event),  evt.tx_desc) Description,				
				sch.interval_type as IntervalType, 
				sch.interval as Interval,
				sch.execution_times as ExecutionTimes,
				sch.days_of_week as DaysOfWeek,
				sch.days_of_month as DaysOfMonth,
				sch.is_paused as IsPaused,
				sch.override_date as OverrideDate
				from t_recevent evt 
				left outer join t_recevent_scheduled sch on evt.id_event=sch.id_event				
				where %%%UPPER%%%(evt.tx_type) = ('SCHEDULED') AND   
				evt.dt_activated <= %%%SYSTEMDATE%%% AND (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated)
 			