
SELECT 
  dt_start,
  dt_end,
  tx_interval_status
FROM t_usage_interval
WHERE id_interval = %%ID_INTERVAL%%
		