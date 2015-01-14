
        select 
				id_pi_instance, 
				vbp.n_kind,
				vbp.n_name, 
				vbp.n_desc, 
				vbp.n_display_name,
				vbp.nm_name,				
				COALESCE(vbp.nm_desc, bp.nm_desc) nm_desc,
				COALESCE(vbp.nm_display_name, bp.nm_display_name) nm_display_name,
				rec.n_rating_type n_rating_type
        from t_pl_map
		join t_base_props bp on bp.id_prop = id_pi_instance
        left join t_vw_base_props vbp on vbp.id_prop = bp.id_prop and vbp.id_lang_code = %%ID_LANG%%
        left outer join t_recur rec on t_pl_map.id_pi_instance = rec.id_prop
        where id_pi_instance_parent = %%ID_PARENT%% and id_paramtable is NULL
      