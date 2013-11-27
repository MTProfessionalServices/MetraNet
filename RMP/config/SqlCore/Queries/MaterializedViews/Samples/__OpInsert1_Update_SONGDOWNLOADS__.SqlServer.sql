
if object_id('tempdb..#SUMMARY_DELTA_INSERT_T_MV_SONGDOWNLOADS') is not null drop table #SUMMARY_DELTA_INSERT_T_MV_SONGDOWNLOADS

select 
au.id_acc,au.id_usage_interval,sum(isnull(au.amount,0)) amount,sum(isnull(c_totalsongs,0)) c_totalsongs,
sum(isnull(c_totalbytes,0)) c_totalbytes,count(*) NumTransactions
into #SUMMARY_DELTA_INSERT_T_MV_SONGDOWNLOADS
from %%DELTA_INSERT_T_ACC_USAGE%% au with(readcommitted)
inner join T_PV_SONGDOWNLOADS pv with(readcommitted) on au.id_sess = pv.id_sess and au.id_usage_interval=pv.id_usage_interval
group by au.id_acc,au.id_usage_interval
--Update the existing rows in the MV table and keep all the changes in the delta_delete and delta_insert mv table
insert into %%DELTA_DELETE_SONGDOWNLOADS%% select dm_1.*
      from %%SONGDOWNLOADS%% dm_1 inner join #SUMMARY_DELTA_INSERT_T_MV_SONGDOWNLOADS tmp2 
      on dm_1.id_acc=tmp2.id_acc
      and dm_1.id_usage_interval=tmp2.id_usage_interval

update dm_1 set 
	  dm_1.amount = IsNULL(dm_1.amount,0.0) + IsNULL(tmp2.amount, 0.0),
      dm_1.c_totalsongs = IsNULL(dm_1.c_totalsongs,0.0) + IsNULL(tmp2.c_totalsongs, 0.0), 
      dm_1.c_totalbytes = IsNULL(dm_1.c_totalbytes,0.0) + IsNULL(tmp2.c_totalbytes, 0.0), 
      dm_1.NumTransactions = IsNULL(dm_1.NumTransactions,0.0) + IsNULL(tmp2.NumTransactions, 0.0) 
      from %%SONGDOWNLOADS%% dm_1 inner join #SUMMARY_DELTA_INSERT_T_MV_SONGDOWNLOADS tmp2 
      on dm_1.id_acc=tmp2.id_acc
      and dm_1.id_usage_interval=tmp2.id_usage_interval

insert into %%DELTA_INSERT_SONGDOWNLOADS%% select dm_1.*
      from %%SONGDOWNLOADS%% dm_1 inner join #SUMMARY_DELTA_INSERT_T_MV_SONGDOWNLOADS tmp2 
      on dm_1.id_acc=tmp2.id_acc
      and dm_1.id_usage_interval=tmp2.id_usage_interval
--Add the new rows into the MV table from the summary delta table and keep all the changes in MV delta_insert table
insert into %%DELTA_INSERT_SONGDOWNLOADS%% select tmp2.* 
from #SUMMARY_DELTA_INSERT_T_MV_SONGDOWNLOADS tmp2 where not exists 
(select 1 from %%SONGDOWNLOADS%% dm_1 where dm_1.id_acc=tmp2.id_acc and dm_1.id_usage_interval=tmp2.id_usage_interval)

insert into %%SONGDOWNLOADS%% select id_acc,id_usage_interval,amount,c_totalsongs,c_totalbytes,NumTransactions 
from #SUMMARY_DELTA_INSERT_T_MV_SONGDOWNLOADS tmp2 where not exists 
(select 1 from %%SONGDOWNLOADS%% dm_1 where dm_1.id_acc=tmp2.id_acc and dm_1.id_usage_interval=tmp2.id_usage_interval)

if object_id('tempdb..#SUMMARY_DELTA_INSERT_T_MV_SONGDOWNLOADS') is not null drop table #SUMMARY_DELTA_INSERT_T_MV_SONGDOWNLOADS
			