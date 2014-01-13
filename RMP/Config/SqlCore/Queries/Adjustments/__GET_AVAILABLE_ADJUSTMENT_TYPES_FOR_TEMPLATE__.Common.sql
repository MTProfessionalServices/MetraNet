
select 
aty.id_prop, 
aty.n_adjustmentType, 
aty.b_supportBulk, 
case when namedesc.tx_desc is null then bp.nm_name else namedesc.tx_desc end as nm_name, 
case when descdesc.tx_desc is null then bp.nm_desc else descdesc.tx_desc end as nm_desc, 
case when dispdesc.tx_desc is null then bp.nm_display_name else dispdesc.tx_desc end as nm_display_name
from t_adjustment_type aty
inner join t_base_props bp on aty.id_prop=bp.id_prop
inner join t_pi_template tmp on aty.id_pi_type=tmp.id_pi
left outer join t_description namedesc on namedesc.id_desc=bp.n_name
left outer join t_description dispdesc on dispdesc.id_desc=bp.n_display_name
left outer join t_description descdesc on descdesc.id_desc=bp.n_desc
where
tmp.id_template=%%ID_PI%%
and
(namedesc.id_lang_code is null or namedesc.id_lang_code=%%ID_LANG_CODE%%)
and
(dispdesc.id_lang_code is null or dispdesc.id_lang_code=%%ID_LANG_CODE%%)
and
(descdesc.id_lang_code is null or descdesc.id_lang_code=%%ID_LANG_CODE%%)
and 
not exists (
	select *
	from t_adjustment a
	where 
	a.id_adjustment_type=aty.id_prop
	and a.id_pi_instance is null
	and a.id_pi_template = tmp.id_template
)
			