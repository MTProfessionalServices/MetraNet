
/* ===========================================================
Get the interval for the given start date and end dates.
============================================================== */
SELECT id_interval
FROM t_usage_interval ui
WHERE ui.dt_start = %%DT_START%% AND
      ui.dt_end = %%DT_END%% AND
      tx_interval_status != 'H'
 