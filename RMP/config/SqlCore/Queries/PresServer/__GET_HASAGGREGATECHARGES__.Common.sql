
select 
CASE WHEN COUNT(*) > 0 THEN 'Y' ELSE 'N' END as HasAggregate
from
t_account_ancestor s1 
/* Join usage to the originator in effect when the usage was generated. */
inner join t_acc_usage au on s1.id_descendent=au.id_payee and s1.vt_start <= au.dt_session and s1.vt_end >= au.dt_session 
inner join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
inner join t_base_props pi_type_props on pi_type_props.id_prop=piTemplated2.id_pi
where
s1.id_ancestor= %%ID_ACC%% and s1.num_generations >= 0
and
s1.vt_start <= %%DT_END%% and s1.vt_end >= %%DT_BEGIN%%
and
pi_type_props.n_kind = 15 
and 
%%TIME_PREDICATE%%
                