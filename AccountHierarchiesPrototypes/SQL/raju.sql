select 
						   parent.id_ancestor parent_id,
						   parent.id_descendent child_id,
						   parent.b_children children,
						   map.nm_login nm_login,
						   tav.c_folder folder,
						   accstate.status status,
         accstate.vt_start,
         accstate.vt_end,
         accpr.id_payer payer
					from 
						   t_account_ancestor parent
						   -- get nm_login
						   INNER JOIN vw_mps_acc_mapper map on map.id_acc = parent.id_descendent 
						   -- get folder		 
						   INNER JOIN t_av_internal tav on tav.id_acc = parent.id_descendent 
						   -- get account state 
						   inner join t_account_state accstate on 
						   		 accstate.id_acc = parent.id_descendent and
					 	    	 -- account state effective dates
         --MTDateInRange(accstate.vt_start,accstate.vt_end, '07-Feb-02') = 1
									accstate.vt_start = (SELECT max (vt_start) FROM t_account_state
											    WHERE id_acc = parent.id_descendent)
						   -- get account payment redirection payer if exists
						   left outer join t_payment_redirection accpr on
  								 accpr.id_payer = parent.id_descendent and
						    	 -- payment redirection effective dates
	  						--MTDateInRange(accpr.vt_start,accpr.vt_end, '07-Feb-02') = 1
									accpr.vt_start = (SELECT max (vt_start) FROM t_payment_redirection
										    WHERE id_acc = parent.id_descendent)
					where
						 	 parent.id_ancestor = 145  and 
							 parent.num_generations = 1 and
							 MTDateInRange(parent.vt_start,parent.vt_end, '07-Feb-02') = 1	
        
        
--SELECT * FROM t_account_mapper WHERE nm_login = 'Engineering'
SELECT * FROM t_account_mapper WHERE nm_login = 'jose2'
SELECT * FROM t_account_mapper WHERE id_acc = 190
SELECT * FROM t_account_mapper WHERE nm_login = 'jose2'
SELECT * FROM t_account_state WHERE id_acc = 193 ORDER BY vt_start;
SELECT * FROM t_account_ancestor WHERE id_descendent = 193
UPDATE t_account_state SET vt_end = getutcdate WHERE status = 'SU' AND id_acc = 146; 
UPDATE t_account_state SET vt_start = getutcdate WHERE status = 'AC' AND id_acc = 146 AND vt_end = '1-Jan-2038'
INSERT INTO t_account_state VALUES (146, 'SU', ', '1-Jan-2038');
COMMIT;

select * from t_Payment_Redirection where ID_payer = 133;
select * from t_payment_redirection

select * from t_account_state where id_acc = 146 and vt_start = (
select max (vt_start) from t_account_state where id_acc = 146)

select * from t_Acc_usage

SELECT a.id_acc accountid, state.vt_start accountstartdate,
				state.vt_end accountenddate,
				b.nm_login username, b.nm_space name_space,d.c_currency currency, '' password_,
				uc.day_of_month dayofmonth, uc.day_of_week dayofweek, uc.first_day_of_month firstdayofmonth, 
				uc.second_day_of_month seconddayofmonth, uc.start_day startday,
				uc.start_month startmonth, uc.start_year startyear
				FROM 
				t_account a
				INNER JOIN t_account_state state on state.id_acc = a.id_acc
				AND state.vt_start <= getutcdate() and getutcdate() < state.vt_end
				INNER JOIN t_account_mapper b on b.id_acc = a.id_acc
				INNER JOIN t_av_internal d on d.id_acc = a.id_acc
				INNER JOIN t_acc_usage_cycle auc on auc.id_acc = a.id_acc
				INNER JOIN t_usage_cycle uc on uc.id_usage_cycle = auc.id_usage_cycle
				INNER JOIN t_usage_cycle_type uct on uct.id_cycle_type = uc.id_cycle_type
				INNER JOIN t_namespace on b.nm_space ='csr'
				WHERE 
	b.id_acc = 131
 
 select * from t_Account_state
 
select DISTINCT(t_sub.id_po), 
				t_sub.id_sub,t_sub.id_acc,t_sub.id_po,
				t_sub.vt_start dt_start,t_sub.vt_end dt_end,
				tb_po.n_name po_n_name, tb_po.nm_name po_nm_name,
				tb_po.n_display_name po_n_display_name,
				tb_po.nm_display_name po_nm_display_name,
				decode(sign( 
				(select count(id_pi_type) from t_pl_map,t_base_props tb
                                where tb.id_prop = t_pl_map.id_pi_type AND tb.n_kind = 20
				and id_po = t_sub.id_po)),1,'Y','N') as b_RecurringCharge,
      				decode(sign(
				(select count(id_po) from t_pl_map where
				id_po = t_sub.id_po AND t_pl_map.id_sub = t_sub.id_sub)),1,'Y','N')
                                as b_PersonalRate,
				t_po.b_user_unsubscribe b_user_unsubscribe
			    ,t_ep_po.c_ExternalInformationURL t_ep__c_ExternalInformationURL,
       t_ep_po.c_glcode t_ep_po_c_glcode,t_ep_po.c_InternalInformationURL t_ep__c_InternalInformationURL
				from t_pl_map map,t_base_props tb_pi,t_base_props tb_po,
				t_sub,
				{oj t_po LEFT OUTER JOIN t_ep_po on t_ep_po.id_prop = t_po.id_po}
				where t_sub.id_acc = 191 and
				map.id_po = t_sub.id_po
				and tb_pi.id_prop =  map.id_pi_type
				and tb_po.id_prop = map.id_po
				and t_po.id_po=map.id_po
				and t_sub.id_acc = 191
				AND (('Y' = 'Y' AND t_sub.vt_end >= GetUTCDate()) or
				('Y' = 'N' AND t_sub.vt_end < GetUTCDate()))


SELECT c_taxexempt, c_TaxExemptID, c_timezoneID, c_PaymentMethod, c_SecurityQuestion, c_SecurityAnswer, c_InvoiceMethod, c_UsageCycleType, c_Language, c_StatusReason, c_StatusReasonOther, c_currency, c_pricelist, c_billable, c_folder      FROM t_av_internal a WHERE a.id_acc = 123 
select              a.id_acc,              astate.vt_start dt_start,              astate.vt_end dt_end,              i.c_currency tx_currency,             u.id_usage_cycle id_usage_cycle          from            t_account a,            t_account_state astate,            t_av_internal i,           t_acc_usage_cycle u        where             a.id_acc = 123 and             a.id_acc = i.id_acc and            a.id_acc = u.id_acc and             a.id_acc = astate.id_acc and            astate.vt_start = (select max (vt_start) from t_account_state where id_acc = 123)

select * from t_pv_accountcredit
select * from t_pv_error

select * from t_payment_redirection
select * from t_Acc_usage where id_sess = 17514
