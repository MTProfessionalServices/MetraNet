
        select id_po,
          t_vw_base_props.id_prop,
          t_vw_base_props.n_name, t_vw_base_props.n_desc, t_vw_base_props.n_display_name,
          t_vw_base_props.nm_name, t_vw_base_props.nm_desc, t_vw_base_props.nm_display_name,
          b_user_subscribe, b_user_unsubscribe, dt_start te_dt_start, dt_end te_dt_end,
          nm_currency_code, t_po.c_POPartitionId
         from t_vw_base_props
        INNER JOIN t_po on id_prop = id_po
        INNER JOIN t_effectivedate te on te.id_eff_date = t_po.id_avail AND
        %%REFDATE%% >= te.dt_start AND (%%REFDATE%% <= te.dt_end or te.dt_end is NULL)
        INNER JOIN t_pricelist pl on t_po.id_nonshared_pl = pl.id_pricelist
        where t_vw_base_props.n_kind = 100 and t_vw_base_props.id_lang_code = %%ID_LANG%% 
		%%PARTITIONFILTER%%
        order by nm_currency_code        