SELECT ui.id_interval,
       TO_CHAR(dt_start, 'mm/dd/yyyy') dt_start,
       TO_CHAR(dt_end, 'mm/dd/yyyy') dt_end
FROM   t_usage_interval ui
WHERE  ui.tx_interval_status = 'B'
       AND EXISTS (
               SELECT au.id_usage_interval
               FROM   t_acc_usage au
               WHERE  au.id_usage_interval = ui.id_interval
           )
ORDER BY
       ui.dt_end