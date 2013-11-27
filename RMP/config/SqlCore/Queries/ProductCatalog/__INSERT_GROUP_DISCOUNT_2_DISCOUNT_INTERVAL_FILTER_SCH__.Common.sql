
   /* For scheduled adapter select usage by date range and process discount instances that are fixed cycle */
   di.dt_end BETWEEN %%DT_ARG_START%% AND %%DT_ARG_END%% and disc.id_usage_cycle IS NOT NULL
