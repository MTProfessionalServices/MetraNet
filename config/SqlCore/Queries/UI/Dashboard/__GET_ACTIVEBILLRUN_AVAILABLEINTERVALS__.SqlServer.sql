SELECT ui.id_interval,
       CONVERT(VARCHAR(10), ui.dt_start, 101) AS dt_start,
       CONVERT(VARCHAR(10), ui.dt_end, 101) AS dt_end
FROM   t_usage_interval ui
WHERE  ui.tx_interval_status = 'O'
       AND EXISTS (
               SELECT au.id_usage_interval
               FROM   t_acc_usage au
               WHERE  au.id_usage_interval = ui.id_interval
           )
ORDER BY
       ui.dt_end;