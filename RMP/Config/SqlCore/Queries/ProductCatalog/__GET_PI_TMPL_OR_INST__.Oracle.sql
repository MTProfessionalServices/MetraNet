/* __GET_PI_TMPL_OR_INST__ */
select 
  tbp.id_prop id_prop, 
  tbp.nm_name nm_name,
  tbp.nm_desc nm_desc,
  tbp.nm_display_name nm_display_name,
  tbp.n_display_name n_display_name,
  tbp.n_kind n_kind,
  tpi.id_pi as id_pi_type, 
  tpi.id_template_parent as id_pi_parent,
  CAST(NULL AS INT) id_pi_template, 
  CAST(NULL AS INT) id_po,
  tbp.n_desc n_desc
from t_pi_template tpi
  INNER JOIN t_base_props tbp ON tbp.id_prop = tpi.id_template  
where 
  tbp.id_prop = %%ID_PI%% and 
  rownum < 2
union
select 
  tbp.id_prop id_prop,
  tbp.nm_name nm_name,
  tbp.nm_desc nm_desc,
  tbp.nm_display_name nm_display_name,
  tbp.n_display_name n_display_name,
  tbp.n_kind n_kind,
  tpl.id_pi_type, 
  tpl.id_pi_instance_parent as id_pi_parent,
  tpl.id_pi_template, 
  tpl.id_po,
  tbp.n_desc n_desc
from t_pl_map tpl 
  INNER JOIN t_base_props tbp ON tbp.id_prop = tpl.id_pi_instance 
where
  tpl.id_paramtable is null and
  tbp.id_prop = %%ID_PI%% and
  rownum < 2
					