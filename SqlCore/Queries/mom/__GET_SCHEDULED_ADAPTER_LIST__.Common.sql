SELECT evt.id_event EventId, 
		COALESCE(loc.tx_name, evt.tx_display_name) DisplayName,
		COALESCE(loc.tx_desc,  evt.tx_desc) Description,			
		sch.interval_type as IntervalType, 
		sch.interval as Interval,
		sch.execution_times as ExecutionTimes,
		sch.days_of_week as DaysOfWeek,
		sch.days_of_month as DaysOfMonth,
		sch.is_paused as IsPaused,
		sch.override_date as OverrideDate
		FROM t_recevent evt 
		left outer join t_recevent_scheduled sch on evt.id_event=sch.id_event
		left outer join t_localized_items loc on (id_local_type = 1  /*Adapter type*/ AND id_lang_code = %%ID_LANG_CODE%% AND evt.id_event=loc.id_item) 
		WHERE %%%UPPER%%%(evt.tx_type) = ('SCHEDULED') AND   
		evt.dt_activated <= %%%SYSTEMDATE%%% AND (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated)