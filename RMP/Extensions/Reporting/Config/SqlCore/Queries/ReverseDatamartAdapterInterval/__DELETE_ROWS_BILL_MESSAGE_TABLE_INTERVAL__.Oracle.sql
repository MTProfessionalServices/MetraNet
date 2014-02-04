
	   begin
 	     if table_exists('%%NETMETER_REPORTING_DB_NAME%%.t_rpt_bill_messages') and
			table_exists('%%NETMETER_REPORTING_DB_NAME%%.t_rpt_invoice') then
			delete from %%NETMETER_REPORTING_DB_NAME%%.t_bill_messages bms
			WHERE EXISTS (SELECT * FROM %%NETMETER_REPORTING_DB_NAME%%.t_rpt_bill_messages bm
						  inner join %%NETMETER_REPORTING_DB_NAME%%.t_rpt_invoice inv
						  on inv.invoiceid = bm.invoiceid where bms.intervalid = %%ID_INTERVAL%%);
			end if;
		end;
	   