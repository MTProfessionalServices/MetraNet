
		  IF EXISTS (SELECT * FROM master..sysdatabases where name = '%%REPORTING_DB_NAME%%')
		  BEGIN
			DROP DATABASE %%REPORTING_DB_NAME%%
			delete from %%NETMETER_DB_NAME%%..t_ReportingDBLog where NameOfReportingDB = '%%REPORTING_DB_NAME%%'
		  END
	  