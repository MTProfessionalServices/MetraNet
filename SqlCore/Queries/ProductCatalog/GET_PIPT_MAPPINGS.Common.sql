
  select 
    map.id_pt, 
    COALESCE(vbp.nm_name, tbp.nm_name) as nm_name, 
    COALESCE(vbp.nm_desc, tbp.nm_desc) as nm_desc,
    COALESCE(vbp.nm_display_name, tbp.nm_display_name) as nm_display_name
  from t_pi_rulesetdef_map map
    inner join t_base_props tbp on tbp.id_prop = map.id_pt
    left join t_vw_base_props vbp on vbp.id_prop = tbp.id_prop and vbp.id_lang_code = %%ID_LANG%%
  where map.id_pi = %%ID_PI%%
