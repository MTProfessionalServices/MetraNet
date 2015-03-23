
select 
  tmp.id_template, 
  COALESCE(vbp.nm_name, bp.nm_name) nm_name,
  COALESCE(COALESCE(vbp.nm_display_name, bp.nm_display_name), bp.nm_name) nm_display_name,
  (case when rba.id_pi_template IS NOT NULL then 'TRUE' else 'FALSE' end) supportsRebill
from 
  (
    select  distinct COALESCE(pit1.id_template_parent, pit1.id_template) id_template 
    from t_pi_template pit1
      inner join t_adjustment adj on 
        adj.id_pi_template = pit1.id_template and
        adj.id_pi_template IS NOT NULL
  ) tmp
  inner join t_pi_template pit2 on 
    pit2.id_template = tmp.id_template and
    pit2.id_template_parent IS NULL 
  left outer join
    (
      select adj.id_pi_template 
      from t_adjustment adj 
        inner join t_adjustment_type adj_type on 
          adj_type.id_prop = adj.id_adjustment_type and
          adj_type.n_adjustmentType = 4
    ) rba on 
	tmp.id_template = rba.id_pi_template
  inner join t_base_props bp on bp.id_prop = pit2.id_pi
  left join t_vw_base_props vbp on vbp.id_prop = bp.id_prop and vbp.id_lang_code = %%LANG_ID%%
