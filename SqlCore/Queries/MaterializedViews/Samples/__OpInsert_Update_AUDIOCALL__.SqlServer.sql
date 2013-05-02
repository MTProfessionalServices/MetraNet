
if object_id('tempdb..#SUMMARY_DELTA_INSERT_T_MV_AUDIOCALL') is not null drop table #SUMMARY_DELTA_INSERT_T_MV_AUDIOCALL

select 
au.id_acc,sum(isnull(au.amount,0)) Amount,sum(isnull(c_actualduration,0)) c_actualduration,
sum(isnull(c_bridgeamount,0)) c_bridgeamount,sum(isnull(c_setupcharge,0)) c_setupcharge,count(*) NumTransactions
into #SUMMARY_DELTA_INSERT_T_MV_AUDIOCALL
from %%DELTA_INSERT_T_ACC_USAGE%% au with(readcommitted)
inner join %%DELTA_INSERT_T_PV_AUDIOCONFCALL%% call with(readcommitted) on au.id_sess = call.id_sess and au.id_usage_interval=call.id_usage_interval
left outer join
(select au1.id_parent_sess,
sum(isnull(child1.c_bridgeamount,0)) c_bridgeamount,
sum(isnull(child2.c_setupcharge,0)) c_setupcharge
from %%DELTA_INSERT_T_ACC_USAGE%% au1 with(readcommitted) left outer join %%DELTA_INSERT_T_PV_AUDIOCONFCONNECTION%% child1 with(readcommitted) 
on au1.id_sess=child1.id_sess and au1.id_usage_interval=child1.id_usage_interval
left outer join %%DELTA_INSERT_T_PV_AUDIOCONFFEATURE%% child2 with(readcommitted) 
on au1.id_sess=child2.id_sess and au1.id_usage_interval=child2.id_usage_interval
group by au1.id_parent_sess) child
on au.id_sess = child.id_parent_sess
where au.id_parent_sess is null
group by au.id_acc

--Update the existing rows in the MV table and keep all the changes in the delta_delete and delta_insert mv table
insert into %%DELTA_DELETE_AUDIOCALL%% select dm_1.*
from %%AUDIOCALL%% dm_1 inner join #SUMMARY_DELTA_INSERT_T_MV_AUDIOCALL tmp2 
on dm_1.id_acc=tmp2.id_acc
 
update dm_1 set 
	  dm_1.Amount = IsNULL(dm_1.Amount,0.0) + IsNULL(tmp2.Amount, 0.0),
      dm_1.c_actualduration = IsNULL(dm_1.c_actualduration,0.0) + IsNULL(tmp2.c_actualduration, 0.0), 
      dm_1.c_bridgeamount = IsNULL(dm_1.c_bridgeamount,0.0) + IsNULL(tmp2.c_bridgeamount, 0.0), 
      dm_1.c_setupcharge = IsNULL(dm_1.c_setupcharge,0.0) + IsNULL(tmp2.c_setupcharge, 0.0), 
      dm_1.NumTransactions = IsNULL(dm_1.NumTransactions,0.0) + IsNULL(tmp2.NumTransactions, 0.0) 
      from %%AUDIOCALL%% dm_1 inner join #SUMMARY_DELTA_INSERT_T_MV_AUDIOCALL tmp2 
      on dm_1.id_acc=tmp2.id_acc

insert into %%DELTA_INSERT_AUDIOCALL%% select dm_1.*
from %%AUDIOCALL%% dm_1 inner join #SUMMARY_DELTA_INSERT_T_MV_AUDIOCALL tmp2 
on dm_1.id_acc=tmp2.id_acc

--Add the new rows into the MV table from the summary delta table and keep all the changes in MV delta_insert table
insert into %%DELTA_INSERT_AUDIOCALL%% select tmp2.* from #SUMMARY_DELTA_INSERT_T_MV_AUDIOCALL tmp2 
where not exists 
(select 1 from %%AUDIOCALL%% dm_1 where dm_1.id_acc=tmp2.id_acc)

insert into %%AUDIOCALL%% select id_acc,Amount,c_actualduration,c_bridgeamount,c_setupcharge,
NumTransactions from #SUMMARY_DELTA_INSERT_T_MV_AUDIOCALL tmp2 where not exists 
(select 1 from %%AUDIOCALL%% dm_1 where dm_1.id_acc=tmp2.id_acc)

if object_id('tempdb..#SUMMARY_DELTA_INSERT_T_MV_AUDIOCALL') is not null drop table #SUMMARY_DELTA_INSERT_T_MV_AUDIOCALL
			