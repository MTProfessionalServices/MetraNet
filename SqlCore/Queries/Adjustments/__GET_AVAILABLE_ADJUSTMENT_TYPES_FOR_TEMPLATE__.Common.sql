select 
		aty.id_prop, 
		aty.n_adjustmentType, 
		aty.b_supportBulk, 
		bp.nm_name nm_name, 
		COALESCE(vbp.nm_desc, bp.nm_desc) nm_desc,
		COALESCE(vbp.nm_display_name, bp.nm_display_name) nm_display_name
from t_adjustment_type aty
inner join t_base_props bp on aty.id_prop=bp.id_prop
inner join t_pi_template tmp on aty.id_pi_type=tmp.id_pi
left outer join t_vw_base_props vbp on bp.id_prop = vbp.id_prop and vbp.id_lang_code = %%ID_LANG_CODE%%
where tmp.id_template=%%ID_PI%%
		and not exists (
						select *
						from t_adjustment a
						where 
						a.id_adjustment_type=aty.id_prop
						and a.id_pi_instance is null
						and a.id_pi_template = tmp.id_template
					)
			