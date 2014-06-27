
        select id_template, t_vw_base_props.n_kind,
        t_vw_base_props.n_name, t_vw_base_props.n_desc, t_vw_base_props.n_display_name,
        t_vw_base_props.nm_name, t_vw_base_props.nm_desc, t_vw_base_props.nm_display_name,
        t_vw_base_props.nm_name, t_vw_base_props.nm_desc, t_vw_base_props.nm_display_name, CAST(NULL AS INT) n_rating_type 
        from t_pi_template
        join t_vw_base_props on t_vw_base_props.id_prop = id_template and t_vw_base_props.id_lang_code = %%ID_LANG%%
        where id_template_parent = %%ID_PARENT%%
      