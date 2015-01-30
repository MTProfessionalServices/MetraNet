select 
		aty.id_prop, 
		aty.n_adjustmentType, 
		aty.b_supportBulk, 
		bp.nm_name nm_name, 
		COALESCE(vbp.nm_desc, bp.nm_desc) nm_desc,
		COALESCE(vbp.nm_display_name, bp.nm_display_name) nm_display_name
from t_adjustment_type aty
inner join t_base_props bp on aty.id_prop=bp.id_prop
inner join t_pl_map plm on aty.id_pi_type=plm.id_pi_type
left outer join t_vw_base_props vbp on bp.id_prop = vbp.id_prop and vbp.id_lang_code = %%ID_LANG_CODE%%
where plm.id_pi_instance=%%ID_PI%%
		and plm.id_paramtable is null
		and not exists (
						select *
						from t_adjustment a
						where 
						a.id_adjustment_type=aty.id_prop
						and a.id_pi_instance = plm.id_pi_instance
						and a.id_pi_template is null
					)	