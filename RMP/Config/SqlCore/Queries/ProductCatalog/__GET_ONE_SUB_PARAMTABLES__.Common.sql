SELECT 
  ID_SUB,
  ID_PO,
  ID_PI_INSTANCE,
  ID_PARAMTABLE,
  cast(INSTANCE_NM_NAME as Varchar(1024)) as instance_nm_name,
  N_KIND,
  NM_NAME,
  PT_NM_NAME,
  PT_NM_DISPLAY_NAME,
  PO_NM_NAME,
  PO_NM_DISPLAY_NAME,
  B_PERSONALRATE,
  B_CANICB,
  DT_START,
  DT_END                    
FROM 
(
  select
  sub.id_sub,
	map.id_po,
	map.id_pi_instance,
	map.id_paramtable,
	case 
	  when tb_ip.id_prop is NULL then COALESCE(tb.nm_display_name, tbp.nm_display_name)
	  else dbo.mtconcat(tb_ip.nm_display_name, dbo.mtconcat('/',tb.nm_display_name))
	end as instance_nm_name,
	COALESCE(tb.n_kind, tbp.n_kind) n_kind,
	COALESCE(tb.nm_name, tbp.nm_name) nm_name,
	COALESCE(tb_pt.nm_name, tbp_pt.nm_name) pt_nm_name,
	COALESCE(tb_pt.nm_display_name, tb_pt.nm_name, tbp_pt.nm_display_name, tbp_pt.nm_name) pt_nm_display_name,	
	COALESCE(tb_po.nm_name, tbp_po.nm_name) po_nm_name,
	COALESCE(tb_po.nm_display_name, tbp_po.nm_display_name) po_nm_display_name,
	case 
	  when 
	   (select count(id_sub) from t_pl_map map2 where map2.id_pi_instance = map.id_pi_instance AND
	    map2.id_paramtable = map.id_paramtable and map2.id_sub = %%ID_SUB%%) > 0 then 'Y'
	  else 'N'
	end as b_PersonalRate,
	map.b_canICB,
	sub.vt_start dt_start,
	sub.vt_end dt_end,
	rec.n_rating_type as n_rating_type
  from t_sub sub
	INNER JOIN t_pl_map map ON map.id_po = sub.id_po AND map.id_sub IS NULL AND map.id_paramtable IS NOT NULL
	INNER JOIN t_base_props tbp ON tbp.id_prop = map.id_pi_instance
    LEFT OUTER JOIN t_vw_base_props tb ON tb.id_prop = tbp.id_prop AND tb.id_lang_code = %%LANGCODE%%
	INNER JOIN t_base_props tbp_pt ON tbp_pt.id_prop = map.id_paramtable
	LEFT OUTER JOIN t_vw_base_props tb_pt on tb_pt.id_prop = map.id_paramtable and tb_pt.id_lang_code = %%LANGCODE%%
	INNER JOIN t_base_props tbp_po ON tbp_po.id_prop = map.id_po
	LEFT OUTER JOIN t_vw_base_props tb_po on tb_po.id_prop = map.id_po and tb_po.id_lang_code = %%LANGCODE%%
	LEFT OUTER JOIN t_pi_template on t_pi_template.id_template = map.id_pi_template
	LEFT OUTER JOIN t_vw_base_props tb_ip on  tb_ip.id_prop = map.id_pi_instance_parent AND tb_ip.id_lang_code = %%LANGCODE%%
	LEFT OUTER JOIN t_recur rec on map.id_pi_instance = rec.id_prop 
  where 
    sub.id_sub = %%ID_SUB%%	
) Query
where 
  (n_rating_type = 0 AND upper(pt_nm_name) = upper('metratech.com/udrctiered')) OR
  (n_rating_type = 1 AND upper(pt_nm_name) = upper('metratech.com/udrctapered')) OR 
  (upper(pt_nm_name) NOT IN (upper('metratech.com/udrctapered'), upper('metratech.com/udrctiered')))
