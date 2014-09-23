
				select top 1
				  /* __GET_PI_TMPL_OR_INST__ */
					t_vw_base_props.id_prop, 
					t_vw_base_props.nm_name, 
					t_vw_base_props.nm_desc, 
					t_vw_base_props.nm_display_name, 
					t_vw_base_props.n_display_name,
					t_vw_base_props.n_kind,
					t_pi_template.id_pi as id_pi_type, 
					t_pi_template.id_template_parent as id_pi_parent,
					CAST(NULL AS INT) id_pi_template, 
					CAST(NULL AS INT) id_po,
          t_vw_base_props.n_desc
				from t_vw_base_props, t_pi_template where
					t_vw_base_props.id_prop = t_pi_template.id_template
					and t_vw_base_props.id_prop = %%ID_PI%%
					and t_vw_base_props.id_lang_code = %%ID_LANG%%
				union
				select 
					t_vw_base_props.id_prop, 
					t_vw_base_props.nm_name, 
					t_vw_base_props.nm_desc, 
					t_vw_base_props.nm_display_name, 
					t_vw_base_props.n_display_name,
					t_vw_base_props.n_kind,
					t_pl_map.id_pi_type, 
					t_pl_map.id_pi_instance_parent as id_pi_parent,
					t_pl_map.id_pi_template, 
					t_pl_map.id_po,
          t_vw_base_props.n_desc
				from t_vw_base_props, t_pl_map where
					t_vw_base_props.id_prop = t_pl_map.id_pi_instance
					and t_pl_map.id_paramtable is null
					and t_vw_base_props.id_prop = %%ID_PI%%
					and t_vw_base_props.id_lang_code = %%ID_LANG%%
			