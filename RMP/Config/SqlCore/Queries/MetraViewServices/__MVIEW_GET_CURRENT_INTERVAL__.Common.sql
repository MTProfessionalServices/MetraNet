select
ui.id_interval
from t_acc_usage_interval aui
inner join t_usage_interval ui on aui.id_usage_interval = ui.id_interval
where 1=1
and aui.id_acc = %%ID_ACC%%
and %%DT_NOW%% BETWEEN ui.dt_start AND ui.dt_end