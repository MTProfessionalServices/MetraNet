
				select 
		  dbo.GenGuid() "ID", /* dummy filed as identifier for GridLayout*/	
		  COALESCE(partition_name, N'Non-Partitioned') "PARTITION",	
          case bp.n_kind 
		  when 10 then 'Usage'
	          when 15 then 'Aggregate Rating' 
	          when 20 then 'Recuuring Charges'
		  when 25 then 'Unit Depending Recurring Charges'
	          when 30 then 'Non Recurring Charges' 
	          when 40 then 'Discount' 
	          end as "Adapter Name",
          count(*) "# Transactions Affected",
          am_currency "Currency",
          SUM({fn ifnull(au.Amount, 0.0)}) "Total Monetary Amount" 
				from t_acc_usage au inner join t_vw_base_props bp on au.id_pi_template = bp.id_prop
				inner join t_enum_data enum on enum.id_enum_data = au.id_view
				inner join t_pi_template piTemplated2 on piTemplated2.id_template = au.id_pi_template
                left outer join vw_bus_partition_accounts bpt on bpt.id_acc = au.id_acc
				where id_usage_interval=%%ID_INTERVAL%%
          and id_lang_code=%%ID_LANG_CODE%%
          and piTemplated2.id_template_parent is null	
          and (bp.n_kind <> 15 or upper(enum.nm_enum_data) NOT LIKE '%_TEMP')
          and (bp.n_kind <> 40 or upper(enum.nm_enum_data) NOT LIKE '%_TEMP')
          and bp.n_kind in (10,15,20,25,30,40) 
				group by partition_name,bp.n_kind,am_currency
