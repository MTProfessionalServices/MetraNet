
	   begin
	    if table_exists('%%NETMETER_REPORTING_DB_NAME%%.t_rpt_invoice') then
			delete from %%NETMETER_REPORTING_DB_NAME%%.t_rpt_invoice inv
			WHERE EXISTS (SELECT 1 FROM %%NETMETER_DB_NAME%%.t_billgroup_member bgm
						        WHERE inv.AccountID = bgm.id_acc AND
						              bgm.id_billgroup = %%ID_BILLGROUP%% AND
							            inv.intervalid in (SELECT id_usage_interval 
                                             FROM %%NETMETER_DB_NAME%%.t_billgroup
												                     WHERE id_billgroup = %%ID_BILLGROUP%%));
			end if;
		end;
	   