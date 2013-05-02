
select tmp.id_acc, am.displayname as accountname,
       'Batch Group Subscription failed' as description, tmp.status
  from %%DEBUG%%tmp_subscribe_batch tmp 
  inner join vw_mps_acc_mapper am on am.id_acc = tmp.id_acc
 where tmp.status <> 0
		