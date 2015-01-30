WITH cycle_type as 
   (SELECT id_cycle_type as id 
   FROM t_acc_usage_cycle, 
      t_usage_cycle 
   WHERE t_acc_usage_cycle.id_acc = :idAcc 
      and t_usage_cycle.id_usage_cycle = t_acc_usage_cycle.id_usage_cycle
   ) 
SELECT DISTINCT (t_po.id_po), 
   t_po.id_eff_date, 
   t_po.id_avail, 
   t_po.b_user_subscribe, 
   t_po.b_user_unsubscribe, 
   t_base_props.n_name, 
   t_base_props.n_desc, 
   t_base_props.n_display_name, 
   t_base_props.nm_name, 
   NVL((SELECT tx_desc as nm_desc 
   FROM t_description 
   WHERE id_desc       = t_base_props.n_desc 
      and id_lang_code = :idLangcode
   ), t_base_props.nm_desc) as nm_desc,    
   NVL((SELECT tx_desc as nm_display_name 
   FROM t_description 
   WHERE id_desc       = t_base_props.n_display_name 
      and id_lang_code = :idLangcode
   ), t_base_props.nm_name) as nm_display_name, 
   te.n_begintype   as te_n_begintype, 
   te.dt_start      as te_dt_start, 
   te.n_beginoffset as te_n_beginoffset, 
   te.n_endtype     as te_n_endtype, 
   te.dt_end        as te_dt_end, 
   te.n_endoffset   as te_n_endoffset, 
   ta.n_begintype   as ta_n_begintype, 
   ta.dt_start      as ta_dt_start, 
   ta.n_beginoffset as ta_n_beginoffset, 
   ta.n_endtype     as ta_n_endtype, 
   ta.dt_end        as ta_dt_end, 
   ta.n_endoffset   as ta_n_endoffset, 
   template_po_map.b_recurringcharge, 
   template_po_map.b_discount1 as b_discount,
   t_po.c_POPartitionId  
   %%COLUMNS%% 
FROM 
   (SELECT :refDate now 
   FROM dual
   ) 
   cdate, 
   %%JOINS%%, 
   t_effectivedate te, 
   t_effectivedate ta, 
   t_base_props, 
   (SELECT template_po_map0.id_po, 
      CASE 
         WHEN max (template_po_map0.yesno) = 1 
         THEN 'Y' 
         ELSE 'N' 
      END 
      b_recurringcharge, 
      CASE 
         WHEN max (template_po_map0.yesnodiscount ) = 1 
         THEN 'Y' 
         ELSE 'N' 
      END 
      b_discount1 
   FROM 
      (
        select 
        /*+ 
        index(t_pl_map t_pl_dc_nl_ndx) 
        use_nl(tb)
        */
        t_pl_map.id_po,
        CASE WHEN tb.n_kind = 20 AND COUNT (*) > 0 THEN 1 ELSE 0 END yesno,
        CASE WHEN tb.n_kind = 40 AND COUNT (*) > 0 THEN 1 ELSE 0 END yesnodiscount
        FROM t_pl_map
        INNER JOIN t_pricelist ON t_pricelist.id_pricelist = t_pl_map.id_pricelist
        INNER JOIN (
            SELECT c_currency AS payercurrency 
            FROM t_payment_redirection pr 
            LEFT OUTER JOIN t_av_internal tav ON tav.id_acc = pr.id_payer 
            WHERE pr.id_payee = :idAcc 
        ) tmp ON %%CURRENCYFILTER2%%
        INNER JOIN t_base_props tb ON tb.id_prop = t_pl_map.id_pi_template
        INNER JOIN t_av_internal tav on tav.id_acc = :idAcc 
        WHERE  1=1
        AND DECODE (to_char(t_pl_map.id_paramtable), NULL, 1, 0) = 0
        AND DECODE (to_char(t_pl_map.id_sub), NULL, 1, 0) = 1
        AND DECODE (to_char(t_pl_map.id_acc), NULL, 1, 0) = 1
        AND id_po NOT IN (
            SELECT   /*+ INDEX(t_po) INDEX(inner_te) */
            DISTINCT subs.id_po
            FROM t_vw_effective_subs subs
            INNER JOIN t_po ON t_po.id_po = subs.id_po
            INNER JOIN t_effectivedate inner_te ON inner_te.id_eff_date = t_po.id_eff_date
            WHERE subs.id_acc = :idAcc 
            /*
            %%CURRENCYFILTER1%%
            %%CURRENCYFILTER3%%
            */
            AND ( (subs.dt_end = inner_te.dt_end) OR (inner_te.dt_end IS NULL AND subs.dt_end = dbo.mtmaxdate ()))
            AND subs.dt_start <= :refDate
        )
        GROUP BY t_pl_map.id_po, tb.n_kind
      ) 
      template_po_map0 
   WHERE not exists 
      (SELECT 1 
      FROM t_pl_map 
      LEFT OUTER JOIN t_recur rc 
         ON rc.id_prop = t_pl_map.id_pi_template 
         or rc.id_prop = t_pl_map.id_pi_instance 
      LEFT OUTER JOIN t_discount 
         ON t_discount.id_prop = t_pl_map.id_pi_template 
         or t_discount.id_prop = t_pl_map.id_pi_instance 
      LEFT OUTER JOIN t_aggregate 
         ON t_aggregate.id_prop = t_pl_map.id_pi_template 
         or t_aggregate.id_prop = t_pl_map.id_pi_instance 
      WHERE t_pl_map.id_po      = template_po_map0.id_po 
         and t_pl_map.id_paramtable is null 
         and ( ( rc.tx_cycle_mode = 'BCR Constrained' 
         and rc.id_cycle_type    <> 
         (SELECT id 
         FROM cycle_type
         ) ) 
         or ( rc.tx_cycle_mode = 'EBCR' 
         and dbo.checkebcrcycletypecompatible (rc.id_cycle_type, 
         (SELECT id 
         FROM cycle_type
         ) 
         ) = 0 ) 
         or ( t_discount.id_cycle_type is not null 
         and t_discount.id_cycle_type <> 
         (SELECT id 
         FROM cycle_type
         ) ) 
         or ( t_aggregate.id_cycle_type is not null 
         and t_aggregate.id_cycle_type <> 
         (SELECT id 
         FROM cycle_type
         ) ) )
      ) 
   GROUP BY template_po_map0.id_po
   ) 
   template_po_map 
WHERE te.id_eff_date  = t_po.id_eff_date 
   and ta.id_eff_date = t_po.id_avail 
   and 
   /* Check dates */ ( ta.dt_start <= cdate.now 
   or ta.dt_start is null) 
   and ( cdate.now <= ta.dt_end 
   or ta.dt_end is null) 
   and te.n_begintype      <> 0 
   and ta.n_begintype      <> 0 
   and t_base_props.id_prop = t_po.id_po 
   and t_po.id_po           = template_po_map.id_po 
   and t_po.id_po in 
   (SELECT id_po 
   FROM vw_acc_po_restrictions 
   WHERE id_acc = :idAcc
   )
   %%PARTITIONFILTER%%