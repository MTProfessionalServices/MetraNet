
 	     if EXISTS ((select name from %%NETMETER_REPORTING_DB_NAME%%..sysobjects where name = 't_rpt_child_summary' and xtype = 'U'))
			 AND EXISTS((select name from %%NETMETER_REPORTING_DB_NAME%%..sysobjects where name = 't_rpt_invoice' and xtype = 'U'))
		delete %%NETMETER_REPORTING_DB_NAME%%..t_rpt_child_summary
		from %%NETMETER_REPORTING_DB_NAME%%..t_rpt_child_summary child
		inner join %%NETMETER_REPORTING_DB_NAME%%..t_rpt_invoice inv
		on inv.invoiceid = child.invoiceid
		where inv.intervalid = %%ID_INTERVAL%%
	   