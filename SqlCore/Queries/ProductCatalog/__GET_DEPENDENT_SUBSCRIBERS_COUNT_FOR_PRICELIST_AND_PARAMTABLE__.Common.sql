
select
/* __GET_DEPENDENT_SUBSCRIBERS_COUNT_FOR_PRICELIST_AND_PARAMTABLE__ */
count(distinct id_acc) as NumberDependentSubscribers from
(
select sub.id_acc 
from t_vw_allrateschedules_po rspo inner join 
t_vw_expanded_sub sub on rspo.id_po=sub.id_po
where id_paramtable=%%ID_PARAMTABLE%% and id_pricelist=%%ID_PRICELIST%%
union all
select acc.id_acc
from t_vw_allrateschedules_pl rspl join 
t_av_internal acc on rspl.id_pricelist=acc.c_pricelist
where id_paramtable=%%ID_PARAMTABLE%% and id_pricelist=%%ID_PRICELIST%%
) a
  