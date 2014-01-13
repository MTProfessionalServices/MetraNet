
if object_id('tempdb..#SUMMARY_DELTA_DELETE_T_MV_SONGDOWNLOADS') is not null drop table #SUMMARY_DELTA_DELETE_T_MV_SONGDOWNLOADS

select 
au.id_acc,au.id_usage_interval,sum(isnull(au.amount,0)) amount,sum(isnull(c_totalsongs,0)) c_totalsongs,
sum(isnull(c_totalbytes,0)) c_totalbytes,count(*) NumTransactions
into #SUMMARY_DELTA_DELETE_T_MV_SONGDOWNLOADS
from %%DELTA_DELETE_T_ACC_USAGE%% au with(readcommitted)
inner join T_PV_SONGDOWNLOADS pv with(readcommitted) on au.id_sess = pv.id_sess and au.id_usage_interval=pv.id_usage_interval
group by au.id_acc,au.id_usage_interval
--Update the existing rows in the MV table and keep all the changes in the delta_delete and delta_insert mv table the existing rows in the MV table and keep all the changes in the delta_delete and delta_insert mv table
insert into %%DELTA_DELETE_SONGDOWNLOADS%% select dm_1.*
      from %%SONGDOWNLOADS%% dm_1 inner join #SUMMARY_DELTA_DELETE_T_MV_SONGDOWNLOADS tmp2 
      on dm_1.id_acc=tmp2.id_acc
      and dm_1.id_usage_interval=tmp2.id_usage_interval

update dm_1 set 
	  dm_1.amount = IsNULL(dm_1.amount,0.0) - IsNULL(tmp2.amount, 0.0),
      dm_1.c_totalsongs = IsNULL(dm_1.c_totalsongs,0.0) - IsNULL(tmp2.c_totalsongs, 0.0), 
      dm_1.c_totalbytes = IsNULL(dm_1.c_totalbytes,0.0) - IsNULL(tmp2.c_totalbytes, 0.0), 
      dm_1.NumTransactions = IsNULL(dm_1.NumTransactions,0.0) - IsNULL(tmp2.NumTransactions, 0.0) 
      from %%SONGDOWNLOADS%% dm_1 inner join #SUMMARY_DELTA_DELETE_T_MV_SONGDOWNLOADS tmp2 
      on dm_1.id_acc=tmp2.id_acc
      and dm_1.id_usage_interval=tmp2.id_usage_interval

insert into %%DELTA_INSERT_SONGDOWNLOADS%% select dm_1.*
      from %%SONGDOWNLOADS%% dm_1 inner join #SUMMARY_DELTA_DELETE_T_MV_SONGDOWNLOADS tmp2 
      on dm_1.id_acc=tmp2.id_acc
      and dm_1.id_usage_interval=tmp2.id_usage_interval
--Delete the MV rows that have NumTransactions=0 i.e. corresponding rows in the base tables are deleted
/* ESR-2908 delete with same predicate as previous update */
delete from %%SONGDOWNLOADS%% dm_1 inner join #SUMMARY_DELTA_DELETE_T_MV_SONGDOWNLOADS  tmp2 
      on dm_1.id_acc=tmp2.id_acc
      and dm_1.id_usage_interval=tmp2.id_usage_interval
      where dm_1.NumTransactions <= 0

if object_id('tempdb..#SUMMARY_DELTA_DELETE_T_MV_SONGDOWNLOADS') is not null drop table #SUMMARY_DELTA_DELETE_T_MV_SONGDOWNLOADS
			