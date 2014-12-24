
SELECT DISTINCT 
       t_po.id_po,
       tbp.id_prop,
       tbp.n_name,
       tbp.n_desc,
       tbp.n_display_name,
       tbp.nm_name,
       tbp.nm_desc,
       tbp.nm_display_name,
       b_user_subscribe,
       b_user_unsubscribe,
       dt_start te_dt_start,
       dt_end te_dt_end,
       nm_currency_code,
       t_po.c_POPartitionId
FROM   t_base_props tbp
       INNER JOIN t_po
            ON  id_prop = id_po
       INNER JOIN t_pl_map tplm
            ON  tplm.id_po = t_po.id_po
            AND tplm.id_pricelist IS NOT NULL
       INNER JOIN t_pricelist tpl
            ON  tpl.id_pricelist = tplm.id_pricelist
       INNER JOIN t_av_internal tavi
            ON  tavi.id_acc = %%CORPORATEACCOUNT%%
       INNER JOIN t_effectivedate te
            ON  te.id_eff_date = t_po.id_avail
            AND %%REFDATE%% >= te.dt_start
            AND (%%REFDATE%% <= te.dt_end OR te.dt_end IS NULL)
WHERE  tbp.n_kind = 100
       AND %%CURRENCYFILTER3%% /* tavi.c_currency = tpl.nm_currency_code */ 
           %%PARTITIONFILTER%%
