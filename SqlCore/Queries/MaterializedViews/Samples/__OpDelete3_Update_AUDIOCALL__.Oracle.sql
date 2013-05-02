
begin

delete from %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_audiocall;

insert into %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_audiocall
select 
au.id_acc,sum(nvl(au.amount,0)) Amount,sum(nvl(c_actualduration,0)) c_actualduration,
sum(nvl(c_bridgeamount,0)) c_bridgeamount,sum(nvl(c_setupcharge,0)) c_setupcharge,count(*) NumTransactions
from %%DELTA_DELETE_T_ACC_USAGE%% au 
inner join %%DELTA_DELETE_T_PV_AUDIOCONFCALL%% call  
on au.id_sess = call.id_sess and au.id_usage_interval=call.id_usage_interval
left outer join
(select au1.id_parent_sess,
sum(nvl(child1.c_bridgeamount,0)) c_bridgeamount,
sum(nvl(child2.c_setupcharge,0)) c_setupcharge
from %%DELTA_DELETE_T_ACC_USAGE%% au1  left outer join %%DELTA_DELETE_T_PV_AUDIOCONFCONNECTION%% child1 
on au1.id_sess=child1.id_sess and au1.id_usage_interval=child1.id_usage_interval
left outer join T_PV_AUDIOCONFFEATURE child2  
on au1.id_sess=child2.id_sess and au1.id_usage_interval=child2.id_usage_interval
group by au1.id_parent_sess) child
on au.id_sess = child.id_parent_sess
where au.id_parent_sess is null
group by au.id_acc;

/* Update the existing rows in the MV table and keep all the changes in the delta_delete and delta_insert mv table */
insert into %%DELTA_DELETE_AUDIOCALL%% select dm_1.*
from %%AUDIOCALL%% dm_1 inner join %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_audiocall tmp2 
on dm_1.id_acc=tmp2.id_acc;

update %%AUDIOCALL%% dm_1 set 
	  (Amount,c_actualduration,c_bridgeamount,c_setupcharge,NumTransactions)
	   = (select nvl(dm_1.Amount,0.0) - nvl(tmp2.Amount, 0.0),
      nvl(dm_1.c_actualduration,0.0) - nvl(tmp2.c_actualduration, 0.0), 
      nvl(dm_1.c_bridgeamount,0.0) - nvl(tmp2.c_bridgeamount, 0.0), 
      nvl(dm_1.c_setupcharge,0.0) - nvl(tmp2.c_setupcharge, 0.0), 
      nvl(dm_1.NumTransactions,0.0) - nvl(tmp2.NumTransactions, 0.0) 
      from %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_audiocall tmp2 
      where dm_1.id_acc=tmp2.id_acc)
 where exists (select 1
      from %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_audiocall tmp2 
      where dm_1.id_acc=tmp2.id_acc);

insert into %%DELTA_INSERT_AUDIOCALL%% select dm_1.*
from %%AUDIOCALL%% dm_1 inner join %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_audiocall tmp2 
on dm_1.id_acc=tmp2.id_acc;

/* Delete the MV rows that have NumTransactions=0 i.e. corresponding rows in the base tables are deleted */
/* ESR-2908 delete from audiocall with the same predicate that was used to do previous update of audiocall */
delete from %%AUDIOCALL%% dm_1
 where exists (select 1
      from %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_audiocall tmp2 
      where dm_1.id_acc=tmp2.id_acc
       and  dm_1.NumTransactions <= 0);

end;
			