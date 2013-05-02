
	    if EXISTS (select name from %%NETMETER_REPORTING_DB_NAME%%..sysobjects where name = 't_rpt_invoice' and xtype = 'U')
		delete inv from %%NETMETER_REPORTING_DB_NAME%%..t_rpt_invoice inv
		where inv.intervalid = %%ID_INTERVAL%%		
	   