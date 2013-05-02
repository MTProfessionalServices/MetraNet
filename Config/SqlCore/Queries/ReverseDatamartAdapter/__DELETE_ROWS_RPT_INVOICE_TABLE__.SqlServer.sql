
	     if EXISTS (select name from %%NETMETER_REPORTING_DB_NAME%%..sysobjects where name = 't_rpt_invoice' and xtype = 'U')
		delete inv from %%NETMETER_REPORTING_DB_NAME%%..t_rpt_invoice inv
		inner join %%NETMETER_DB_NAME%%..t_billgroup_member bgm
		on inv.AccountID = bgm.id_acc
		and inv.intervalid in (select id_usage_interval from %%NETMETER_DB_NAME%%..t_billgroup
							   where id_billgroup = %%ID_BILLGROUP%%)
		where bgm.id_billgroup = %%ID_BILLGROUP%% 
	   