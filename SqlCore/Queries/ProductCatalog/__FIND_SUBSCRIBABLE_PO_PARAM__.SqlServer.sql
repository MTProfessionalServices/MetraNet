
					SELECT
					distinct(t_po.id_po),
					t_po.id_eff_date, 
					t_po.id_avail,	
					t_po.b_user_subscribe, 
					t_po.b_user_unsubscribe,
					t_base_props.n_name, 
					t_base_props.n_desc, 
					t_base_props.n_display_name,
					t_base_props.nm_name, 
					ISNULL((select tx_desc as nm_desc from t_description	where id_desc = t_base_props.n_desc and id_lang_code=@idLangcode),  t_base_props.nm_desc) nm_desc,
					ISNULL((select tx_desc as nm_display_name from t_description	where id_desc = t_base_props.n_display_name and id_lang_code=@idLangcode), t_base_props.nm_name) nm_display_name,
					te.n_begintype as te_n_begintype, 
					te.dt_start as te_dt_start,
					te.n_beginoffset as te_n_beginoffset,
					te.n_endtype as te_n_endtype, 
					te.dt_end as te_dt_end, 
					te.n_endoffset as te_n_endoffset,
					ta.n_begintype as ta_n_begintype, 
					ta.dt_start as ta_dt_start, 
					ta.n_beginoffset as ta_n_beginoffset,
					ta.n_endtype as ta_n_endtype, 
					ta.dt_end as ta_dt_end, 
					ta.n_endoffset as ta_n_endoffset,
					template_po_map.b_RecurringCharge,
					template_po_map. b_Discount1 as b_Discount,
					t_po.c_POPartitionId 
					%%COLUMNS%%
					FROM
						(select @refDate now) cdate,
						%%JOINS%%,
						t_effectivedate te,
						t_effectivedate ta,
						t_base_props,
						(
						SELECT template_po_map0.id_po, 
						case when MAX(template_po_map0.YesNo)= 1 then 'Y' else 'N' end b_RecurringCharge,
						case when MAX(template_po_map0. YesNoDiscount)= 1 then 'Y' else 'N' end b_Discount1
						from  
							(
							
							SELECT
									t_pl_map.id_po
									,case when (tb.n_kind = 20 or tb.n_kind = 25) and count(*) > 0 then 1 else 0 end YesNo
									,case when tb.n_kind = 40 and count(*) > 0 then 1 else 0 end YesNoDiscount
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
										  where subs.id_acc = @idAcc
										   /* allow the user to see the product offering if they are not subscribed till the end of  */
										   /* of the effective date interval */
										   AND ((subs.dt_end = inner_te.dt_end) OR (inner_te.dt_end is NULL and subs.dt_end = dbo.mtmaxdate()))
										   AND subs.dt_start <= @refDate
										) TMP2 ON TMP2.id_po = t_pl_map.id_po ,
									(
										SELECT c_Currency as PayerCurrency
										FROM t_po po
										inner join t_pricelist pl1 on pl1.id_pricelist = po.id_nonshared_pl
										inner join t_payment_redirection pr ON pr.id_payee = @idAcc
										inner join t_av_internal tav ON tav.id_acc = pr.id_payer AND /* pl1.nm_currency_code = tav.c_Currency */
                                                                                %%CURRENCYFILTER1%% 
                                                                              AND %%CURRENCYFILTER3%%
										where 
										tav.c_Currency IS NOT NULL
										GROUP BY c_Currency
									) TMP
							WHERE 
									/* Check currency */
									t_pricelist.id_pricelist = t_pl_map.id_pricelist AND
									/* TMP.PayerCurrency = t_pricelist.nm_currency_code AND */
									%%CURRENCYFILTER2%% AND
									t_pl_map.id_paramtable is not NULL AND t_pl_map.id_sub is NULL AND t_pl_map.id_acc is NULL AND
									tb.id_prop = t_pl_map.id_pi_template
									/* Not already have */
									and tmp2.ID_PO is null
							GROUP BY t_pl_map.id_po, tb.n_kind
							) template_po_map0
						where
							not exists (

							SELECT 1
							FROM 
                (select id_cycle_type
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
                 (rc.tx_cycle_mode = 'EBCR' AND dbo.CheckEBCRCycleTypeCompatibility(rc.id_cycle_type, cycleType.id_cycle_type) = 0) OR
								(t_discount.id_cycle_type is not null and t_discount.id_cycle_type <> cycleType.id_cycle_type) or
								(t_aggregate.id_cycle_type is not null and t_aggregate.id_cycle_type <> cycleType.id_cycle_type)))
						GROUP BY template_po_map0.id_po
						) template_po_map
					WHERE 
					te.id_eff_date = t_po.id_eff_date AND
					ta.id_eff_date = t_po.id_avail AND
					/* Check dates */
					(ta.dt_start <= cdate.now or ta.dt_start is null) AND 
					(cdate.now  <= ta.dt_end or ta.dt_end is null) AND
					te.n_begintype <> 0 AND 
					ta.n_begintype <> 0 AND
					t_base_props.id_prop = t_po.id_po AND
					t_po.id_po = template_po_map.id_po AND
					t_po.id_po in (select id_po from vw_acc_po_restrictions where id_acc=@idAcc)
					%%PARTITIONFILTER%%