
				select
				  dbo.GenGuid() "ID", /* dummy filed as identifier for GridLayout*/	
		  		  COALESCE(partition_name, N'Non-Partitioned') "PARTITION",
				  sub.tx_name "Group Subscription",
				  bpd2.nm_name "PO Subscribed to",
				  bp3d2.nm_name "Discount Name",
				  count(*) "# of Discounts Generated",
				  au.am_currency "Currency",
				  SUM({fn ifnull(au.Amount, 0.0)}) "Amount"
				from t_acc_usage au
				inner join t_gsubmember gsub on au.id_acc = gsub.id_acc
				inner join t_group_sub sub on sub.id_group = gsub.id_group 
				inner join t_enum_data enum on enum.id_enum_data = au.id_view
				inner join t_pi_template piTemplated2 on piTemplated2.id_template = au.id_pi_template
				inner join t_sub sub1 on sub.id_group = sub1.id_group
				inner join t_vw_base_props bpd2 on sub1.id_po = bpd2.id_prop
				inner join t_vw_base_props bp3d2 on au.id_pi_template = bp3d2.id_prop
                left outer join vw_bus_partition_accounts bpt on bpt.id_acc = au.id_acc
				where id_usage_interval = %%ID_INTERVAL%%
				  and bpd2.id_lang_code = %%ID_LANG_CODE%%
				  and bp3d2.id_lang_code = %%ID_LANG_CODE%%
				  and bp3d2.n_kind = 40
				  and piTemplated2.id_template_parent is null	
	    		and (bp3d2.n_kind <> 15 or upper(enum.nm_enum_data) NOT LIKE '%_TEMP')
	    		and (bp3d2.n_kind <> 40 or upper(enum.nm_enum_data) NOT LIKE '%_TEMP')
				group by partition_name,sub.tx_name, bpd2.nm_name, bp3d2.nm_name, am_currency 
