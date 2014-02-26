select
pv.c_eventdate as dt_transaction,
pv.c_description,
au.amount,
au.am_currency
from t_usage_interval tui
inner join t_pv_payment pv on pv.id_usage_interval = tui.id_interval
inner join t_acc_usage au on au.id_usage_interval = pv.id_usage_interval and au.id_sess = pv.id_sess
where 1=1
and au.id_acc = %%ACCOUNT_ID%%
and pv.c_eventdate >= %%DT_START%%