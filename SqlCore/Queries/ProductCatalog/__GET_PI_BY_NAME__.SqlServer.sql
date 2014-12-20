
				select 
					id_pi, 
					id_parent, 
					nm_servicedef, 
					nm_productview, 
					b_constrain_cycle,
					t_vw_base_props.n_name, 
					t_vw_base_props.n_desc, 
					t_vw_base_props.n_display_name,
					t_vw_base_props.nm_name, 
					t_vw_base_props.nm_desc, 
					t_vw_base_props.nm_display_name, 
					t_vw_base_props.n_kind
				from t_pi,t_vw_base_props
				where t_vw_base_props.id_prop = t_pi.id_pi AND
				t_vw_base_props.nm_name = '%%NAME%%'
				and t_vw_base_props.id_lang_code = %%ID_LANG%%
			