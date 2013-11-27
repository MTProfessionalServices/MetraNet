
Delete from %%FASHIONSALE%% where id_usage_interval not in 
(select id_interval from t_archive where status = 'A' and tt_end = dbo.mtmaxdate())

Insert into %%FASHIONSALE%%
select 
au.id_acc,au.id_usage_interval,sum(isnull(au.tax_federal,0)) + sum(isnull(au.tax_state,0))
+ sum(isnull(au.tax_county,0)) + sum(isnull(au.tax_local,0)) + sum(isnull(au.tax_other,0)), 
sum(isnull(c_totalprice,0)),count(*)
from T_ACC_USAGE au
inner join T_PV_FASHIONSALE pv on au.id_sess = pv.id_sess and au.id_usage_interval=pv.id_usage_interval
group by au.id_acc,au.id_usage_interval
			