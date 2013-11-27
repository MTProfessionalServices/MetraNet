
	   begin
	    if table_exists('%%NETMETER_REPORTING_DB_NAME%%.t_rpt_parent_summary') and
			table_exists('%%NETMETER_REPORTING_DB_NAME%%.t_rpt_invoice') then
			DELETE FROM %%NETMETER_REPORTING_DB_NAME%%.t_rpt_parent_summary parent
      WHERE EXISTS (SELECT 1 FROM %%NETMETER_REPORTING_DB_NAME%%.t_rpt_invoice inv 
                    INNER JOIN %%NETMETER_DB_NAME%%.t_billgroup_member bgm ON bgm.id_acc = inv.accountid
                    WHERE inv.invoiceid = parent.invoiceid AND
                          bgm.id_billgroup = %%ID_BILLGROUP%% AND
                          inv.intervalid in (SELECT id_usage_interval 
                                             FROM %%NETMETER_DB_NAME%%.t_billgroup
																             WHERE id_billgroup = %%ID_BILLGROUP%%));   
			end if;
		end;
	   