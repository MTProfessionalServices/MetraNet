select
au.id_sess as PaymentId,
pv.c_eventdate as PaymentDate,
pv.c_description as PaymentDescription,
'Visa Ending:4564' as PaymentTypeDescription, /* TODO: Fix */
pv.c_Source as PaymentSource,
pv.c_ReferenceID as PaymentReferenceId,
au.amount as PaymentAmount,
au.am_currency as Currency
from t_usage_interval tui
inner join t_pv_payment pv on pv.id_usage_interval = tui.id_interval
inner join t_acc_usage au on au.id_usage_interval = pv.id_usage_interval and au.id_sess = pv.id_sess
where 1=1
and au.id_acc = %%ACCOUNT_ID%%
/*and pv.c_eventdate >= */

