
	   begin
	    if table_exists('%%NETMETER_REPORTING_DB_NAME%%.t_rpt_parent_summary') and 
			table_exists('%%NETMETER_REPORTING_DB_NAME%%.t_rpt_invoice') then
			delete from %%NETMETER_REPORTING_DB_NAME%%.t_rpt_parent_summary
			WHERE EXISTS (SELECT * FROM %%NETMETER_REPORTING_DB_NAME%%.t_rpt_parent_summary parent
						  inner join %%NETMETER_REPORTING_DB_NAME%%.t_rpt_invoice inv
						  on inv.invoiceid = parent.invoiceid	where inv.intervalid = %%ID_INTERVAL%%);	
			end if;
		end;
	   