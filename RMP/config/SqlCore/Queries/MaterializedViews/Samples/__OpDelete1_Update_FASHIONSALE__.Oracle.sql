
begin

delete from %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_fashionsale;

Insert into %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_fashionsale
select 
au.id_acc,au.id_usage_interval,sum(nvl(au.tax_federal,0)) + sum(nvl(au.tax_state,0))
+ sum(nvl(au.tax_county,0)) + sum(nvl(au.tax_local,0)) + sum(nvl(au.tax_other,0)) taxes,
sum(nvl(c_totalprice,0)) c_totalprice,count(*) NumTransactions
from %%DELTA_DELETE_T_ACC_USAGE%% au 
inner join T_PV_FASHIONSALE pv  on au.id_sess = pv.id_sess and au.id_usage_interval=pv.id_usage_interval
group by au.id_acc,au.id_usage_interval;

/* Update the existing rows in the MV table and keep all the changes in the delta_delete and delta_insert mv table */

insert into %%DELTA_DELETE_FASHIONSALE%% select dm_1.*
      from %%FASHIONSALE%% dm_1 inner join %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_fashionsale tmp2 
      on dm_1.id_acc=tmp2.id_acc
      and dm_1.id_usage_interval=tmp2.id_usage_interval;

update %%FASHIONSALE%% dm_1  set 
	  (dm_1.taxes,dm_1.c_totalprice,dm_1.NumTransactions) = (select nvl(dm_1.taxes,0.0) - nvl(tmp2.taxes, 0.0),
       nvl(dm_1.c_totalprice,0.0) - nvl(tmp2.c_totalprice, 0.0), 
       nvl(dm_1.NumTransactions,0.0) - nvl(tmp2.NumTransactions, 0.0) 
      from %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_fashionsale tmp2 
      where dm_1.id_acc=tmp2.id_acc
      and dm_1.id_usage_interval=tmp2.id_usage_interval)
     where exists
     (select 1 
      from %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_fashionsale tmp2 
      where dm_1.id_acc=tmp2.id_acc
      and dm_1.id_usage_interval=tmp2.id_usage_interval);

insert into %%DELTA_INSERT_FASHIONSALE%% select dm_1.*
      from %%FASHIONSALE%% dm_1 inner join %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_fashionsale tmp2 
      on dm_1.id_acc=tmp2.id_acc
      and dm_1.id_usage_interval=tmp2.id_usage_interval;

/* Delete the MV rows that have NumTransactions=0 i.e. corresponding rows in the base tables are deleted */
/* ESR-2908 delete from FashionSale with the same predicate that was used to do previous update of FashionSale */
delete from %%FASHIONSALE%% dm_1
     (select 1 
      from %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_fashionsale tmp2 
      where dm_1.id_acc=tmp2.id_acc
      and dm_1.id_usage_interval=tmp2.id_usage_interval
      and dm_1.NumTransactions <= 0);


end;
			