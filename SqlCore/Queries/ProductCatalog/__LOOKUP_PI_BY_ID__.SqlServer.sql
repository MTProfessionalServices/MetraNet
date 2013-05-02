
		select top 1
		t_base_props.id_prop, t_base_props.nm_name, t_base_props.nm_desc, t_base_props.nm_display_name, t_base_props.n_kind,
		t_pi_template.id_pi as id_pi_type, t_pi_template.id_template_parent as id_pi_parent, NULL as id_pi_template, NULL as id_po
		from t_base_props
		join t_pi_template on t_base_props.id_prop = t_pi_template.id_template
		where t_base_props.id_prop = %%ID_TEMPL%%
		union
		select top 1
		t_base_props.id_prop, t_base_props.nm_name, t_base_props.nm_desc, t_base_props.nm_display_name, t_base_props.n_kind,
		t_pl_map.id_pi_type, t_pl_map.id_pi_instance_parent as id_pi_parent, t_pl_map.id_pi_template, t_pl_map.id_po
		from t_base_props
		join t_pl_map on t_base_props.id_prop = t_pl_map.id_pi_instance
		where t_base_props.id_prop = %%ID_TEMPL%%
  		