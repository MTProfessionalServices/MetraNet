
begin

delete from %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_songdownloads;

insert into %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_songdownloads
select 
au.id_acc,au.id_usage_interval,sum(nvl(au.amount,0)) amount,sum(nvl(c_totalsongs,0)) c_totalsongs,
sum(nvl(c_totalbytes,0)) c_totalbytes,count(*) NumTransactions
from %%DELTA_DELETE_T_ACC_USAGE%% au 
inner join %%DELTA_DELETE_T_PV_SONGDOWNLOADS%% pv  
on au.id_sess = pv.id_sess and au.id_usage_interval=pv.id_usage_interval
group by au.id_acc,au.id_usage_interval;

insert into %%DELTA_DELETE_SONGDOWNLOADS%% select dm_1.*
      from %%SONGDOWNLOADS%% dm_1 inner join %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_songdownloads tmp2 
      on dm_1.id_acc=tmp2.id_acc
      and dm_1.id_usage_interval=tmp2.id_usage_interval;

update %%SONGDOWNLOADS%% dm_1 set 
	  (amount,c_totalsongs,c_totalbytes,NumTransactions) = 
	  (select nvl(dm_1.amount,0.0) - nvl(tmp2.amount, 0.0),
      nvl(dm_1.c_totalsongs,0.0) - nvl(tmp2.c_totalsongs, 0.0), 
      nvl(dm_1.c_totalbytes,0.0) - nvl(tmp2.c_totalbytes, 0.0), 
      nvl(dm_1.NumTransactions,0.0) - nvl(tmp2.NumTransactions, 0.0) 
      from  %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_songdownloads tmp2 
      where dm_1.id_acc=tmp2.id_acc
      and dm_1.id_usage_interval=tmp2.id_usage_interval)
 where exists (select 1 
      from  %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_songdownloads tmp2 
      where dm_1.id_acc=tmp2.id_acc
      and dm_1.id_usage_interval=tmp2.id_usage_interval);

insert into %%DELTA_INSERT_SONGDOWNLOADS%% select dm_1.*
      from %%SONGDOWNLOADS%% dm_1 inner join %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_songdownloads tmp2 
      on dm_1.id_acc=tmp2.id_acc
      and dm_1.id_usage_interval=tmp2.id_usage_interval;

/* ESR-2908 delete songdownloads with the same predicate that was used to do previous update of songdownloads */
delete from %%SONGDOWNLOADS%% dm_1 
 where exists (select 1 
      from  %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_songdownloads tmp2 
      where dm_1.id_acc=tmp2.id_acc
      and dm_1.id_usage_interval=tmp2.id_usage_interval
      and dm_1.NumTransactions <= 0); 

end;
			