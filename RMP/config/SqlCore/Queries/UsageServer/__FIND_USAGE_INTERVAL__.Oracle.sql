select ui.id_interval IntervalID  
        from t_usage_interval ui where ui.id_usage_cycle = %%CYCLE_ID%% 
        and ui.dt_start = TO_DATE ('%%START_DATE%%', 'MM/DD/YYYY')  
        and ui.dt_end = TO_DATE('%%END_DATE%% 23:59:59', 'MM/DD/YYYY HH24:MI:SS')