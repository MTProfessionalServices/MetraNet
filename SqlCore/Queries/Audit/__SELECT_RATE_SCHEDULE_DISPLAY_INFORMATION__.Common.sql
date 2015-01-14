
SELECT rs.id_pt                                          AS ParamTableId,
       COALESCE(vbp.nm_display_name, bp.nm_display_name) AS ParamTableDisplayName,
       COALESCE(vbp.nm_name, bp.nm_name)                 AS ParamTableName,
       rs.id_pricelist                                   AS PriceListId,
       COALESCE(vbp2.nm_name, bp2.nm_name)               AS PriceListName
FROM   t_rsched rs
       JOIN t_base_props bp ON bp.id_prop = rs.id_pt
       LEFT OUTER JOIN t_vw_base_props vbp ON rs.id_pt = vbp.id_prop
            AND vbp.id_lang_code = %%ID_LANG%%
       LEFT OUTER JOIN t_base_props bp2 ON bp2.id_prop = rs.id_pricelist
       LEFT OUTER JOIN t_vw_base_props vbp2 ON bp2.id_prop = vbp2.id_prop
            AND vbp2.id_lang_code = %%ID_LANG%%
WHERE  id_sched = %%RS_ID%%
