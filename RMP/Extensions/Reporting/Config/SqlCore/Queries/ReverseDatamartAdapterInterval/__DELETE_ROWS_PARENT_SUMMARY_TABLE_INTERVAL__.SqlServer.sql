
	     if EXISTS ((select name from %%NETMETER_REPORTING_DB_NAME%%..sysobjects where name = 't_rpt_parent_summary' and xtype = 'U'))
			 AND EXISTS((select name from %%NETMETER_REPORTING_DB_NAME%%..sysobjects where name = 't_rpt_invoice' and xtype = 'U'))
		delete %%NETMETER_REPORTING_DB_NAME%%..t_rpt_parent_summary
		from %%NETMETER_REPORTING_DB_NAME%%..t_rpt_parent_summary parent
		inner join %%NETMETER_REPORTING_DB_NAME%%..t_rpt_invoice inv
		on inv.invoiceid = parent.invoiceid
		where inv.intervalid = %%ID_INTERVAL%%		
	   