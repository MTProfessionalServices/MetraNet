
      select
      t_vw_base_props.id_prop, t_vw_base_props.nm_name, t_vw_base_props.nm_desc, t_vw_base_props.nm_display_name, t_vw_base_props.n_display_name, t_vw_base_props.n_kind,
      t_pi_template.id_pi as id_pi_type, t_pi_template.id_template_parent as id_pi_parent, CAST(NULL AS INT) as id_pi_template, CAST(NULL AS INT) as id_po, t_vw_base_props.n_desc
      from t_vw_base_props
      join t_pi_template on t_vw_base_props.id_prop = t_pi_template.id_template
      where t_vw_base_props.nm_name = '%%NAME%%'
      and t_vw_base_props.id_lang_code = %%ID_LANG%%
    