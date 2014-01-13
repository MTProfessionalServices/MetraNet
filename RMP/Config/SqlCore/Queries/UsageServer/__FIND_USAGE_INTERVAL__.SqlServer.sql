select ui.id_interval IntervalID 
        from t_usage_interval ui where ui.id_usage_cycle = %%CYCLE_ID%%
        and ui.dt_start = '%%START_DATE%%' and ui.dt_end = '%%END_DATE%% 23:59:59'