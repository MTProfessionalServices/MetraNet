
				SELECT
				  dbo.GenGuid() "ID", /* dummy filed as identifier for GridLayout*/
          		  COALESCE(partition_name, N'Non-Partitioned') "PARTITION",
				  CASE 
				    when c_advance = 1 and sum(amount) >= 0.0 THEN 'Advance'
				    when c_advance = 0 THEN 'Arrears' 	
				    when c_advance = 1 and sum(amount) < 0.0 THEN 'Advance Credits' 
				    else null 
				    end as "Type of RC",
				  count(*) "# of Transactions Generated",
				  au.am_currency "Currency",
				  SUM(au.amount) "Amount"
				FROM t_acc_usage au 
				INNER JOIN t_pv_flatrecurringcharge rc 
				  ON au.id_sess = rc.id_sess
				  and au.id_usage_interval = rc.id_usage_interval
				inner join t_vw_base_props bp on au.id_pi_template=bp.id_prop
          	    left outer join vw_bus_partition_accounts bpt on bpt.id_acc = au.id_acc
				where au.id_usage_interval = %%ID_INTERVAL%%
				  and id_lang_code = %%ID_LANG_CODE%%
				group by partition_name,c_advance, au.am_currency
				UNION ALL
				select
					dbo.GenGuid() "ID", /* dummy filed as identifier for GridLayout*/  
                    COALESCE(partition_name, N'Non-Partitioned') "PARTITION",
				  case 
				    when c_advance = 1 and sum(amount) >= 0.0 THEN 'Advance udrc'
				    when c_advance = 0 THEN 'Arrears' 	
				    when c_advance = 1 and sum(amount) < 0.0 THEN 'Advance Credits' 
				    ELSE NULL END as "Type of RC",
				  count(*) "# of Transactions Generated",
				  au.am_currency "Currency",
				  SUM(au.amount) "Amount"
				from t_acc_usage au 
				INNER JOIN t_pv_udrecurringcharge rc 
				  ON au.id_sess = rc.id_sess
				  and au.id_usage_interval = rc.id_usage_interval
				inner join t_vw_base_props bp on au.id_pi_template=bp.id_prop
          	    left outer join vw_bus_partition_accounts bpt on bpt.id_acc = au.id_acc
				where au.id_usage_interval = %%ID_INTERVAL%%
				  and id_lang_code = %%ID_LANG_CODE%%
				group by partition_name,c_advance, au.am_currency
			 