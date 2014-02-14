SELECT DISTINCT (t_po.id_po), 
   t_po.id_eff_date, 
   t_po.id_avail, 
   t_po.b_user_subscribe, 
   t_po.b_user_unsubscribe, 
   t_base_props.n_name, 
   t_base_props.n_desc, 
   t_base_props.n_display_name, 
   t_base_props.nm_name, 
   t_base_props.nm_desc, 
   (SELECT tx_desc as nm_display_name 
   FROM t_description 
   WHERE id_desc       = t_base_props.n_display_name 
      and id_lang_code = :idLangcode
   ) 
   nm_display_name, 
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
   template_po_map.b_discount1 as b_discount 
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
         WHEN max (template_po_map0.yesnodiscount) = 1 
         THEN 'Y' 
         ELSE 'N' 
      END 
      b_discount1 
   FROM 
      (SELECT t_pl_map.id_po, 
         CASE 
            WHEN (tb.n_kind = 20 or tb.n_kind = 25)
            and count (*)  > 0 
            THEN 1 
            ELSE 0 
         END 
         yesno, 
         CASE 
            WHEN tb.n_kind = 40 
            and count (*)  > 0 
            THEN 1 
            ELSE 0 
         END 
         yesnodiscount 
      FROM 
         t_pricelist, 
         t_base_props tb, 
         t_pl_map
		 LEFT OUTER JOIN 		
										(
										  select distinct subs.id_po 
										   from t_vw_effective_subs subs
										   INNER JOIN t_po on t_po.id_po = subs.id_po
										   INNER JOIN t_effectivedate inner_te on inner_te.id_eff_date = t_po.id_eff_date
										  where subs.id_acc = :idAcc
										   /* allow the user to see the product offering if they are not subscribed till the end of  */
										   /* of the effective date interval */
										   AND ((subs.dt_end = inner_te.dt_end) OR (inner_te.dt_end is NULL and subs.dt_end = dbo.mtmaxdate()))
										   AND subs.dt_start <= :refDate
										) tmp2 ON tmp2.id_po = t_pl_map.id_po ,
         (SELECT c_currency  as payercurrency
         FROM t_po po 
         INNER JOIN t_pricelist pl1 
            ON pl1.id_pricelist = po.id_nonshared_pl 
         INNER JOIN t_payment_redirection pr 
            ON pr.id_payee = :idAcc 
         LEFT OUTER JOIN t_av_internal tav 
            ON tav.id_acc            = pr.id_payer 
             and  %%CURRENCYFILTER1%%
	/* and pl1.nm_currency_code = tav.c_currency */ 
         WHERE tav.c_currency is not null 
         GROUP BY c_currency
         ) tmp 
      WHERE 
         /* Check currency */ 
         t_pricelist.id_pricelist = t_pl_map.id_pricelist 
         and  %%CURRENCYFILTER2%%
	 /* and tmp.payercurrency        = t_pricelist.nm_currency_code */ 
         and t_pl_map.id_paramtable is not null 
         and t_pl_map.id_sub is null 
         and t_pl_map.id_acc is null 
         and tb.id_prop = t_pl_map.id_pi_template 
         /* Not already have */
									and tmp2.ID_PO is null
							GROUP BY t_pl_map.id_po, tb.n_kind
							) template_po_map0         
   WHERE NOT EXISTS (
							SELECT 1
							FROM 
                (SELECT id_cycle_type
					        from t_acc_usage_cycle, t_usage_cycle
				          where t_acc_usage_cycle.id_acc = @idAcc
				          AND t_usage_cycle.id_usage_cycle = t_acc_usage_cycle.id_usage_cycle ) cycleType,
                t_pl_map
                LEFT OUTER JOIN t_recur rc ON rc.id_prop = t_pl_map.id_pi_template OR rc.id_prop = t_pl_map.id_pi_instance
                LEFT OUTER JOIN t_discount on t_discount.id_prop = t_pl_map.id_pi_template  OR t_discount.id_prop = t_pl_map.id_pi_instance
                LEFT OUTER JOIN t_aggregate on t_aggregate.id_prop = t_pl_map.id_pi_template  OR t_aggregate.id_prop = t_pl_map.id_pi_instance
							WHERE
								t_pl_map.id_po = template_po_map0.id_po and t_pl_map.id_paramtable is null and 
								((rc.tx_cycle_mode = 'BCR Constrained' AND rc.id_cycle_type <> cycleType.id_cycle_type) OR
                 (rc.tx_cycle_mode = 'EBCR' AND dbo.CheckEBCRCycleTypeCompatible(rc.id_cycle_type, cycleType.id_cycle_type) = 0) OR
								(t_discount.id_cycle_type is not null and t_discount.id_cycle_type <> cycleType.id_cycle_type) or
								(t_aggregate.id_cycle_type is not null and t_aggregate.id_cycle_type <> cycleType.id_cycle_type)))
						GROUP BY template_po_map0.id_po
						) template_po_map
WHERE te.id_eff_date  = t_po.id_eff_date 
   and ta.id_eff_date = t_po.id_avail 
   and 
   /* Check dates */ 
   (ta.dt_start <= cdate.now or ta.dt_start is null) 
   and (cdate.now <= ta.dt_end or ta.dt_end is null) 
   and te.n_begintype      <> 0 
   and ta.n_begintype      <> 0 
   and t_base_props.id_prop = t_po.id_po 
   and t_po.id_po           = template_po_map.id_po 
   and t_po.id_po in (SELECT id_po FROM vw_acc_po_restrictions WHERE id_acc = :idAcc)
   AND
   %%CURRENCYFILTER3%%
   