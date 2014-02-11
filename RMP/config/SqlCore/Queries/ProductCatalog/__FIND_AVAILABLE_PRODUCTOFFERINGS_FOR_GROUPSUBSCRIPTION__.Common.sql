
select DISTINCT t_po.id_po,
  t_vw_base_props.id_prop,
  t_vw_base_props.n_name, t_vw_base_props.n_desc, t_vw_base_props.n_display_name,
  t_vw_base_props.nm_name, t_vw_base_props.nm_desc, t_vw_base_props.nm_display_name,
  b_user_subscribe, b_user_unsubscribe, dt_start te_dt_start, dt_end te_dt_end,
  nm_currency_code, t_po.c_POPartitionId
from t_vw_base_props
  INNER JOIN t_po on id_prop = id_po
  INNER JOIN t_pl_map tplm on ((tplm.id_po = t_po.id_po) AND (tplm.id_pricelist IS NOT NULL))
  INNER JOIN t_pricelist tpl on tpl.id_pricelist = tplm.id_pricelist
  INNER JOIN t_av_internal tavi on tavi.id_acc = %%CORPORATEACCOUNT%%

  INNER JOIN t_effectivedate te on te.id_eff_date = t_po.id_avail AND  %%REFDATE%% >= te.dt_start AND (%%REFDATE%% <= te.dt_end or te.dt_end is NULL)
where t_vw_base_props.n_kind = 100 and t_vw_base_props.id_lang_code = %%ID_LANG%% AND
  %%CURRENCYFILTER3%%  /* tavi.c_currency = tpl.nm_currency_code */        
        