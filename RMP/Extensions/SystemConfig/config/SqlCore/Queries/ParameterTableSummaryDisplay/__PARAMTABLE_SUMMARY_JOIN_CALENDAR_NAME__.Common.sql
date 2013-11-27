
			  LEFT JOIN %%PARAMTABLEDBNAME%% pt on t_rsched.id_sched = pt.id_sched AND pt.tt_start<=%%%SYSTEMDATE%%% AND pt.tt_end>%%%SYSTEMDATE%%%
			  LEFT JOIN t_vw_base_props bp1 on bp1.id_prop = pt.c_calendar_id and bp1.id_lang_code = 840
			