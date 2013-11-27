
begin

Delete from %%SONGDOWNLOADS%% where id_usage_interval not in 
(select id_interval from t_archive where status = 'A' and tt_end = dbo.mtmaxdate());

Insert into %%SONGDOWNLOADS%%
select 
au.id_acc,au.id_usage_interval,sum(nvl(au.amount,0)),sum(nvl(c_totalsongs,0)),
sum(nvl(c_totalbytes,0)),count(*)
from T_ACC_USAGE au
inner join T_PV_SONGDOWNLOADS pv on au.id_sess = pv.id_sess and au.id_usage_interval=pv.id_usage_interval
group by au.id_acc,au.id_usage_interval;
end;
			