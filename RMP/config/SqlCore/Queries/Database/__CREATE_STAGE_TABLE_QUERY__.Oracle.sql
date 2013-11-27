
			begin
				if not %%%NETMETER_PREFIX%%%table_exists('%%%NETMETERSTAGE_PREFIX%%%%%TABLE_NAME%%') then
					%%%NETMETER_PREFIX%%%exec_ddl('%%CREATE_DDL%%');
				end if;
			end;
		