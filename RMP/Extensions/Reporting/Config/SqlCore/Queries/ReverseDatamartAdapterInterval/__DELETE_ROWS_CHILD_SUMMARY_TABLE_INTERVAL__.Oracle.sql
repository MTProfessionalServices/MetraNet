
	   begin
 	     if table_exists('%%NETMETER_REPORTING_DB_NAME%%.t_rpt_child_summary') and
			table_exists('%%NETMETER_REPORTING_DB_NAME%%.t_rpt_invoice') then
			delete from %%NETMETER_REPORTING_DB_NAME%%.t_rpt_child_summary
			WHERE EXISTS (SELECT * FROM %%NETMETER_REPORTING_DB_NAME%%.t_rpt_child_summary child
						  inner join %%NETMETER_REPORTING_DB_NAME%%.t_rpt_invoice inv
						  on inv.invoiceid = child.invoiceid where inv.intervalid = %%ID_INTERVAL%%);
			end if;
		end;
	   