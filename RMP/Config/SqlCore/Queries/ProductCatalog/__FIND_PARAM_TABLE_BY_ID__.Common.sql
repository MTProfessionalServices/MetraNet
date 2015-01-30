select 
  id_paramtable,
  nm_instance_tablename, 
  COALESCE(tvp.n_name, tbp.n_name) n_name,
  COALESCE(tvp.n_desc, tbp.n_desc) n_desc,
  COALESCE(tvp.nm_name, tbp.nm_name) nm_name,
  COALESCE(tvp.nm_desc, tbp.nm_desc) nm_desc
from t_rulesetdefinition tr
  INNER JOIN t_base_props tbp ON tbp.id_prop = tr.id_paramtable
  LEFT OUTER JOIN t_vw_base_props tvp ON tvp.id_prop = tbp.id_prop AND tvp.id_lang_code = %%ID_LANG%%
where 
  tbp.n_kind = 140 AND
  tr.id_paramtable = %%ID%%
