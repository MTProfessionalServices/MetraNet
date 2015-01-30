select
	dbo.GenGuid() "ID",
	COALESCE(pam.nm_login, N'Non-Partitioned') "PARTITION",
	am_currency "Currency", 
	bp.nm_name "Priceable Item", 
	count(*) "# Transactions",
	sum({fn ifnull(au.Amount, 0.0)}) "Total Amount",
	sum(
			{fn ifnull(au.tax_federal, 0.0)} + 
			{fn ifnull(au.tax_state, 0.0)} + 
			{fn ifnull(au.tax_county, 0.0)} + 
			{fn ifnull(au.tax_local, 0.0)} + 
			{fn ifnull(au.tax_other, 0.0)}
		) "Total Tax Amount"
from t_acc_usage au 
inner join t_vw_base_props bp on au.id_pi_template = bp.id_prop
inner join t_enum_data ed on ed.id_enum_data = au.id_view
inner join t_pi_template pit on pit.id_template = au.id_pi_template
join t_billgroup_member bgm on au.id_acc = bgm.id_acc
join t_billgroup bg on bgm.id_root_billgroup = bg.id_billgroup
                       and bg.id_billgroup = %%ID_BILLINGGROUP%%
left outer join t_account_mapper pam on pam.id_acc = bg.id_partition
where au.id_usage_interval = %%ID_INTERVAL%%
  and id_lang_code = %%ID_LANG_CODE%%
  and pit.id_template_parent is null	
  and (bp.n_kind <> 15 or upper(ed.nm_enum_data) NOT LIKE '%_TEMP')
  and (bp.n_kind <> 40 or upper(ed.nm_enum_data) NOT LIKE '%_TEMP')
group by pam.nm_login, am_currency, bp.nm_name
