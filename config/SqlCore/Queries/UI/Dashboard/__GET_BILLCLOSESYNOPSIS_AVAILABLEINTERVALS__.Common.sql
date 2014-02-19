select
ui.id_interval,
dt_start,
dt_end
from t_usage_interval ui
where ui.tx_interval_status = 'O'
and exists ( select au.id_usage_interval from t_acc_usage au where au.id_usage_interval = ui.id_interval)
order by ui.dt_end;
