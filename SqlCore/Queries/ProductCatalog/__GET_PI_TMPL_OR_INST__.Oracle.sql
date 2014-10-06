/* __GET_PI_TMPL_OR_INST__ */
select 
  COALESCE(tvp.id_prop, tbp.id_prop) id_prop, 
  COALESCE(tvp.nm_name, tbp.nm_name) nm_name,
  COALESCE(tvp.nm_desc, tbp.nm_desc) nm_desc,
  COALESCE(tvp.nm_display_name, tbp.nm_display_name) nm_display_name,
  COALESCE(tvp.n_display_name, tbp.n_display_name) n_display_name,
  COALESCE(tvp.n_kind, tbp.n_kind) n_kind,
  tpi.id_pi as id_pi_type, 
  tpi.id_template_parent as id_pi_parent,
  CAST(NULL AS INT) id_pi_template, 
  CAST(NULL AS INT) id_po,
  COALESCE(tvp.n_desc, tbp.n_desc) n_desc
from t_pi_template tpi
  INNER JOIN t_base_props tbp ON tbp.id_prop = tpi.id_template
  LEFT OUTER JOIN t_vw_base_props tvp ON 
    tvp.id_prop = tbp.id_prop and 
    tvp.id_lang_code = %%ID_LANG%%
where 
  tbp.id_prop = %%ID_PI%% and 
  rownum < 2
union
select 
  COALESCE(tvp.id_prop, tbp.id_prop) id_prop,
  COALESCE(tvp.nm_name, tbp.nm_name) nm_name,
  COALESCE(tvp.nm_desc, tbp.nm_desc) nm_desc,
  COALESCE(tvp.nm_display_name, tbp.nm_display_name) nm_display_name,
  COALESCE(tvp.n_display_name, tbp.n_display_name) n_display_name,
  COALESCE(tvp.n_kind, tbp.n_kind) n_kind,
  tpl.id_pi_type, 
  tpl.id_pi_instance_parent as id_pi_parent,
  tpl.id_pi_template, 
  tpl.id_po,
  COALESCE(tvp.n_desc, tbp.n_desc) n_desc
from t_pl_map tpl 
  INNER JOIN t_base_props tbp ON tbp.id_prop = tpl.id_pi_instance
  LEFT OUTER JOIN t_vw_base_props tvp ON 
    tvp.id_prop = tbp.id_prop and
    tvp.id_lang_code = %%ID_LANG%%
where
  tpl.id_paramtable is null and
  tbp.id_prop = %%ID_PI%% and
  rownum < 2
					