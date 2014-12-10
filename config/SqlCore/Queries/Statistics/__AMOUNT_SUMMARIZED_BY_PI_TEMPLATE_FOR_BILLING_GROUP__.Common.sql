
				select 
          dbo.GenGuid() "ID",
          COALESCE(pam.nm_login, N'Non-Partitioned') "PARTITION",
          bp.nm_name "PI Template", 
				  count(*) "# Transactions Affected",
				  am_currency Currency, 
				  SUM({fn ifnull(au.Amount, 0.0)}) "Monetary Amount" 
				from t_acc_usage au 
				inner join t_vw_base_props bp on au.id_pi_template = bp.id_prop
				inner join t_enum_data enum on enum.id_enum_data = au.id_view
				inner join t_pi_template piTemplated2 on piTemplated2.id_template = au.id_pi_template
				inner join t_billgroup_member bgm 
				  on bgm.id_acc = au.id_acc 
				  and bgm.id_billgroup = %%ID_BILLINGGROUP%%
        inner join t_billgroup bg on bgm.id_billgroup = bg.id_billgroup
        left outer join t_account_mapper pam on pam.id_acc = bg.id_partition
				where au.id_usage_interval = %%ID_INTERVAL%%
				  and id_lang_code = %%ID_LANG_CODE%%
				  and piTemplated2.id_template_parent is null	
	    		and (bp.n_kind <> 15 or upper(enum.nm_enum_data) NOT LIKE '%_TEMP')
	    		and (bp.n_kind <> 40 or upper(enum.nm_enum_data) NOT LIKE '%_TEMP')
				group by pam.nm_login, bp.nm_name,am_currency		 