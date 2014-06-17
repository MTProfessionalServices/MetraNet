select
ui.id_interval,
ui.dt_start as dt_start,
ui.dt_end as dt_end
from t_usage_interval ui
where ui.tx_interval_status in ('O', 'B')
/*and exists ( select au.id_usage_interval from t_acc_usage au where au.id_usage_interval = ui.id_interval) */
order by ui.dt_end
