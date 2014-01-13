
				select 
				  nm_name "PI Template",
				  count(c_advance) "# of Arrears Generated",
				  c_prorateddays "# of Days Prorated",
				  case 
				    when c_proratedonsubscription = 1 and c_proratedonunsubscription=1 then 'BOTH'
				    when c_proratedonsubscription = 1 and c_proratedonunsubscription=0 then 'SUBSCRIPTION'
				    when c_proratedonsubscription = 0 and c_proratedonunsubscription=1 then 'UNSUBSCRIPTION'
    				when c_proratedonsubscription = 0 and c_proratedonunsubscription=0 then 'N/A' 
    				end as "Reason for Proration", 
          trunc(c_rcintervalend - c_rcintervalstart) + 1 as  "# of Days in Period",
				  am_currency "Currency",
				  SUM(nvl(au.Amount, 0.0)) "Amount",
				  SUM(nvl(c_rcamount, 0.0)) "Amount if it weren't Prorated"
				from t_acc_usage au 
				inner join t_pv_flatrecurringcharge rc 
				  on au.id_sess=rc.id_sess 
				  and au.id_usage_interval = rc.id_usage_interval
				inner join t_vw_base_props bp on au.id_pi_template=bp.id_prop
				where c_advance=0
				  and au.id_usage_interval=%%ID_INTERVAL%%
				  and id_lang_code=%%ID_LANG_CODE%%
				group by nm_name,am_currency,c_prorateddays,
				  case 
				    when c_proratedonsubscription = 1 and c_proratedonunsubscription=1 then 'BOTH'
				    when c_proratedonsubscription = 1 and c_proratedonunsubscription=0 then 'SUBSCRIPTION'
				    when c_proratedonsubscription = 0 and c_proratedonunsubscription=1 then 'UNSUBSCRIPTION'
				    when c_proratedonsubscription = 0 and c_proratedonunsubscription=0 then 'N/A' end,
          trunc(c_rcintervalend - c_rcintervalstart) + 1 
			UNION ALL
				select 
				  nm_name "PI Template",
				  count(c_advance) "# of Arrears Generated",
				  c_prorateddays "# of Days Prorated",
				  case 
				    when c_proratedonsubscription = 1 and c_proratedonunsubscription=1 then 'BOTH'
				    when c_proratedonsubscription = 1 and c_proratedonunsubscription=0 then 'SUBSCRIPTION'
				    when c_proratedonsubscription = 0 and c_proratedonunsubscription=1 then 'UNSUBSCRIPTION'
				    when c_proratedonsubscription = 0 and c_proratedonunsubscription=0 then 'N/A' end, 
          trunc(c_rcintervalend - c_rcintervalstart) + 1 as  "# of Days in Period",
				  am_currency "Currency",
				  SUM(nvl(au.Amount, 0.0)) "Amount",
				  SUM(nvl(c_rcamount, 0.0)) "Amount if it weren't Prorated"
				from t_acc_usage au 
				inner join t_pv_udrecurringcharge rc 
				  on au.id_sess=rc.id_sess 
				  and au.id_usage_interval = rc.id_usage_interval
				inner join t_vw_base_props bp on au.id_pi_template=bp.id_prop
				where c_advance=0
				  and au.id_usage_interval=%%ID_INTERVAL%%
				  and id_lang_code=%%ID_LANG_CODE%%
				group by nm_name,am_currency,c_prorateddays,
				  case 
				    when c_proratedonsubscription = 1 and c_proratedonunsubscription=1 then 'BOTH'
				    when c_proratedonsubscription = 1 and c_proratedonunsubscription=0 then 'SUBSCRIPTION'
				    when c_proratedonsubscription = 0 and c_proratedonunsubscription=1 then 'UNSUBSCRIPTION'
				    when c_proratedonsubscription = 0 and c_proratedonunsubscription=0 then 'N/A' end,
          trunc(c_rcintervalend - c_rcintervalstart) + 1
				order by "Reason for Proration"
			 