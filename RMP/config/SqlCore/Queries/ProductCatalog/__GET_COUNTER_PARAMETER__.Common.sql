
   SELECT cp.id_counter_param, Value nm_value, nm_name, nm_desc, nm_display_name, id_pv_prop, nm_op, nm_value predicate_value from t_counter_params cp
   INNER JOIN t_vw_base_props bp ON bp.id_prop = cp.id_counter_param
   LEFT OUTER JOIN t_counter_param_predicate cpp ON cp.id_counter_param = cpp.id_counter_param
   WHERE bp.id_lang_code = %%ID_LANG%%
   AND cp.id_counter_param = %%ID_COUNTER_PARAM%%
  