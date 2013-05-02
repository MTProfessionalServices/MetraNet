
        select 
          t_vw_base_props.id_prop, t_vw_base_props.n_kind,
          t_vw_base_props.n_name, t_vw_base_props.n_desc, t_vw_base_props.n_display_name,
          t_vw_base_props.nm_name, t_vw_base_props.nm_desc, t_vw_base_props.nm_display_name
        from t_vw_base_props
        join t_pl_map on t_vw_base_props.id_prop = t_pl_map.id_pi_template and t_vw_base_props.id_lang_code = %%ID_LANG%%
        where id_pi_instance = %%ID_PI_INSTANCE%% and id_paramtable is null
  