
    SELECT id_counter_param, Value, nm_name, nm_desc, nm_display_name from t_counter_params cp
   INNER JOIN t_vw_base_props bp ON bp.id_prop = cp.id_counter_param
    where bp.id_lang_code = %%ID_LANG%%
    AND cp.id_counter IS NULL
  