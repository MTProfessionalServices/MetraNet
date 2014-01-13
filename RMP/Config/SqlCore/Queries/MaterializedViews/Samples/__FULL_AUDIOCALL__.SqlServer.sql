
truncate table %%AUDIOCALL%%

Insert into %%AUDIOCALL%%
select 
au.id_acc,sum(isnull(au.amount,0)),sum(isnull(c_actualduration,0)),
sum(isnull(c_bridgeamount,0)),sum(isnull(c_setupcharge,0)),count(*)
from T_ACC_USAGE au
inner join T_PV_AUDIOCONFCALL call on au.id_sess = call.id_sess and au.id_usage_interval=call.id_usage_interval
left outer join
(select au1.id_parent_sess,
sum(isnull(child1.c_bridgeamount,0)) c_bridgeamount,
sum(isnull(child2.c_setupcharge,0)) c_setupcharge
from T_ACC_USAGE au1 left outer join T_PV_AUDIOCONFCONNECTION child1 on au1.id_sess=child1.id_sess and au1.id_usage_interval=child1.id_usage_interval
left outer join T_PV_AUDIOCONFFEATURE child2 on au1.id_sess=child2.id_sess and au1.id_usage_interval=child2.id_usage_interval
group by au1.id_parent_sess) child
on au.id_sess = child.id_parent_sess
where au.id_parent_sess is null
group by au.id_acc
			