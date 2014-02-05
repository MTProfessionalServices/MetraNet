
 	     if EXISTS ((select name from %%NETMETER_REPORTING_DB_NAME%%..sysobjects where name = 't_rpt_bill_messages' and xtype = 'U'))
			 AND EXISTS((select name from %%NETMETER_REPORTING_DB_NAME%%..sysobjects where name = 't_rpt_invoice' and xtype = 'U'))
		delete %%NETMETER_REPORTING_DB_NAME%%..t_rpt_bill_messages
		from %%NETMETER_REPORTING_DB_NAME%%..t_rpt_bill_messages bm
		inner join %%NETMETER_REPORTING_DB_NAME%%..t_rpt_invoice inv
		on inv.invoiceid = bm.invoiceid
		and inv.intervalid in (select id_usage_interval from %%NETMETER_DB_NAME%%..t_billgroup
										   where id_billgroup = %%ID_BILLGROUP%%)
		inner join %%NETMETER_DB_NAME%%..t_billgroup_member bgm
		on inv.AccountID = bgm.id_acc
		where bgm.id_billgroup = %%ID_BILLGROUP%%
	   