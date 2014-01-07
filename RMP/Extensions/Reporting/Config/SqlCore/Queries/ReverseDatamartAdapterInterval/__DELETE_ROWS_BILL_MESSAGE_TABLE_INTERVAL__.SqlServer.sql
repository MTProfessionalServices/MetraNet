    if EXISTS (select name from %%NETMETER_REPORTING_DB_NAME%%..sysobjects where name = 't_rpt_bill_messages' and xtype = 'U')
	  AND EXISTS((select name from %%NETMETER_REPORTING_DB_NAME%%..sysobjects where name = 't_rpt_invoice' and xtype = 'U'))
		delete %%NETMETER_REPORTING_DB_NAME%%..t_rpt_bill_messages
		from %%NETMETER_REPORTING_DB_NAME%%..t_rpt_bill_messages bm
		inner join %%NETMETER_REPORTING_DB_NAME%%..t_rpt_invoice inv
		on inv.invoiceid = bm.invoiceid
		where inv.intervalid = %%ID_INTERVAL%%
		delete inv from %%NETMETER_REPORTING_DB_NAME%%..t_rpt_invoice inv
		where inv.intervalid = %%ID_INTERVAL%%		
	   