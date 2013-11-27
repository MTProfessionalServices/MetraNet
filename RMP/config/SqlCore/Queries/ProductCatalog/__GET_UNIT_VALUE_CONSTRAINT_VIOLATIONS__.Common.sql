
select 
/*  __GET_UNIT_VALUE_CONSTRAINT_VIOLATIONS__ */
rv.id_sub, 
rv.n_value, 
rv.id_prop,
case when rv.n_value > r.max_unit_value then 'MAX' else 'MIN' end as constraint_violation
from t_recur_value rv 
inner join t_recur r on rv.id_prop=r.id_prop
where 
rv.tt_end = %%TT_MAX%%
and 
rv.vt_end > %%%SYSTEMDATE%%%
and
(
rv.n_value > r.max_unit_value 
or 
rv.n_value < r.min_unit_value
)
union all
select 
rv.id_sub, 
rv.n_value, 
rv.id_prop,
'ENUM' as constraint_violation
from t_recur_value rv 
where 
rv.tt_end = %%TT_MAX%%
and 
rv.vt_end > %%%SYSTEMDATE%%%
and
exists (select * from t_recur_enum re where re.id_prop=rv.id_prop)
and
not exists (select * from t_recur_enum re where re.id_prop=rv.id_prop and re.enum_value=rv.n_value)		
      