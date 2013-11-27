
      select
      t_vw_base_props.id_prop, t_vw_base_props.nm_name, t_vw_base_props.nm_desc, t_vw_base_props.nm_display_name, t_vw_base_props.n_display_name, t_vw_base_props.n_kind,
      t_pl_map.id_pi_type, t_pl_map.id_pi_instance_parent as id_pi_parent, t_pl_map.id_pi_template, t_pl_map.id_po, t_vw_base_props.n_desc
      from t_vw_base_props
      join t_pl_map on t_vw_base_props.id_prop = t_pl_map.id_pi_instance
      where %%%UPPER%%%(t_vw_base_props.nm_name) = %%%UPPER%%%('%%NAME%%')
      and t_vw_base_props.id_lang_code = %%ID_LANG%%
      and t_pl_map.id_po = %%ID_PO%% and t_pl_map.id_paramtable is NULL
    