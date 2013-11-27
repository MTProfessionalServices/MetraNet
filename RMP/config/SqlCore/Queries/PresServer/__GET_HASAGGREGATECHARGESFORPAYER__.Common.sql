
select 
CASE WHEN COUNT(*) > 0 THEN 'Y' ELSE 'N' END as HasAggregate
from
t_acc_usage au 
inner join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
inner join t_base_props pi_type_props on pi_type_props.id_prop=piTemplated2.id_pi
where
au.id_acc = %%ID_PAYER%%
and
pi_type_props.n_kind = 15 
and 
%%TIME_PREDICATE%%
                