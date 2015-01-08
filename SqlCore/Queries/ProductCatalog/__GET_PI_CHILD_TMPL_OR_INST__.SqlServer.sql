select top 1
	/* __GET_PI_CHILD_TMPL_OR_INST__ */
    bp.id_prop, 
    bp.nm_name, 
    bp.nm_desc, 
    bp.nm_display_name, 
    bp.n_display_name, 
    bp.n_kind,
    t_pi_template.id_pi as id_pi_type,
    t_pi_template.id_template_parent as id_pi_parent,
    NULL as id_pi_template,
    NULL as id_po, bp.n_desc
        from t_base_props bp
        join t_pi_template on bp.id_prop = t_pi_template.id_template
        where bp.id_prop = %%ID_CHILD%%
        and t_pi_template.id_template_parent = %%ID_PARENT%%
        union
        select
    bp.id_prop, 
    bp.nm_name, 
    bp.nm_desc, 
    bp.nm_display_name, 
    bp.nm_display_name, 
    bp.n_kind,
    t_pl_map.id_pi_type,
    t_pl_map.id_pi_instance_parent as id_pi_parent,
    t_pl_map.id_pi_template,
    t_pl_map.id_po,
    bp.n_desc
        from t_base_props bp
        join t_pl_map on bp.id_prop = t_pl_map.id_pi_instance
        where bp.id_prop = %%ID_CHILD%%
        and t_pl_map.id_pi_instance_parent = %%ID_PARENT%% and t_pl_map.id_paramtable is null