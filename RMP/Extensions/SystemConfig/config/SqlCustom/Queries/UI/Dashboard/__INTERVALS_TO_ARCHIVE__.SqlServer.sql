select id_interval, ui.dt_start, ui.dt_end, tx_interval_status
from t_usage_interval ui
where tx_interval_status = 'H' and dt_end < dateadd(month, -24, getdate())
and exists (select null from t_acc_usage au with (nolock) where au.id_usage_interval = ui.id_interval)
order by dt_end 