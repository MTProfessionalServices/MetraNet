
select tmp.id_acc, am.displayname as accountname,
       'Batch Subscription failed' as description, tmp.status
  from %%DEBUG%%tmp_subscribe_individual_batch tmp %%%READCOMMITTED%%%
  inner join vw_mps_acc_mapper am on am.id_acc = tmp.id_acc
 where tmp.status is not null
    