
				select 
				  dbo.GenGuid() "ID", /* dummy filed as identifier for GridLayout*/
                  COALESCE(partition_name, N'Non-Partitioned') "PARTITION",
				  bp.nm_name "COMPOUNDED PI TEMPLATE",
				  count(*) "# Transactions Affected",
				  am_currency Currency,
				  SUM({fn ifnull(au.Amount, 0.0)}) "Monetary Amount" 
				from t_acc_usage au 
				inner join t_vw_base_props bp on au.id_pi_template = bp.id_prop
				inner join t_enum_data enum on enum.id_enum_data = au.id_view
				inner join t_pi_template piTemplated2 on piTemplated2.id_template = au.id_pi_template
                left outer join vw_bus_partition_accounts bpt on bpt.id_acc = au.id_acc
				where 
				  exists (
				    select 1 from t_pi_template
				    where 
				    id_template_parent = au.id_pi_template
				    )
				  and id_usage_interval = %%ID_INTERVAL%%
				  and id_lang_code = %%ID_LANG_CODE%%
				  and piTemplated2.id_template_parent is null	
          and (bp.n_kind <> 15 or upper(enum.nm_enum_data) NOT LIKE '%_TEMP')
  	    	and (bp.n_kind <> 40 or upper(enum.nm_enum_data) NOT LIKE '%_TEMP')
				group by partition_name,bp.nm_name,am_currency

