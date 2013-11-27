select ui.id_interval IntervalID from t_usage_interval ui 
      where ui.id_usage_cycle = %%CYCLE_ID%% and ui.dt_end > '%%END_DATE%%'
      order by ui.dt_start DESC
      