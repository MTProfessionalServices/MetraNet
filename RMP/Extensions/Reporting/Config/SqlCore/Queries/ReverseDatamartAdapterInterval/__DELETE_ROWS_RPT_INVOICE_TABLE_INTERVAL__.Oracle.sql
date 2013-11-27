
	   begin
	    if table_exists('%%NETMETER_REPORTING_DB_NAME%%.t_rpt_invoice') then
			delete from %%NETMETER_REPORTING_DB_NAME%%.t_rpt_invoice
			WHERE EXISTS (SELECT * FROM %%NETMETER_REPORTING_DB_NAME%%.t_rpt_invoice inv
						  where inv.intervalid = %%ID_INTERVAL%%);
			end if;
		end;
	   