select
auat.orig_values_packed, auat.orig_usage_interval, au.*, pv.*
from agg_usage_audit_trail auat
inner join t_acc_usage au on auat.id_usage_interval = au.id_usage_interval and auat.id_sess = au.id_sess
inner join %%NM_PV_TABLE%% pv on pv.id_usage_interval = au.id_usage_interval and pv.id_sess = au.id_sess
where 1=1
and auat.id_usage_interval = %%ID_INTERVAL%% and auat.id_sess = %%ID_SESS%%
