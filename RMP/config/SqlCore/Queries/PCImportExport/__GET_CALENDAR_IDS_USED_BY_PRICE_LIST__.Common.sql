
        select distinct t_pt_calendar.c_calendar_id "id" from t_rsched,t_pt_calendar where
        t_rsched.id_pricelist=%%ID%% and
        t_pt_calendar.id_sched=t_rsched.id_sched
			