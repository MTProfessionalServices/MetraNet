
select 
/* __DISCOUNT_INSTANCE_CYCLE_TYPE_SUMMARY__ */
sum(case when id_usage_cycle is null then 1 else 0 end) as NumBcrDiscountInstances, 
count(*) as NumDiscountInstances
from 
t_pl_map plm
inner join t_discount d on d.id_prop=plm.id_pi_instance
where
plm.id_paramtable is null
			