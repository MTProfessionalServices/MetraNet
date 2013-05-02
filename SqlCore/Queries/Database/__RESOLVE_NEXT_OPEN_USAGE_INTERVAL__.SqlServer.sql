
SELECT TOP 1
-- finds the next open interval for usage to go into
  ui.id_interval,
  ui.dt_start,
  ui.dt_end
FROM t_usage_interval ui
INNER JOIN t_acc_usage_interval aui ON aui.id_usage_interval = ui.id_interval
WHERE
  aui.tx_status = 'O' AND
  -- normalizes the start date of the interval to the effectivity of the mapping if one exists
  ISNULL(dbo.AddSecond(aui.dt_effective), ui.dt_start) >= %%DT_SESSION%% AND
  aui.id_acc = %%ID_ACC%%
ORDER BY
  -- returns the earliest open intervals first
  ui.dt_start ASC
