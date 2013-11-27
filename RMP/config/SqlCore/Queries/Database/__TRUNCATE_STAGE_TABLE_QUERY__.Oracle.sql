
			begin
				if %%%NETMETER_PREFIX%%%table_exists('%%%NETMETERSTAGE_PREFIX%%%%%TABLE_NAME%%') then
					%%%NETMETER_PREFIX%%%exec_ddl('TRUNCATE TABLE %%%NETMETERSTAGE_PREFIX%%%%%TABLE_NAME%%');
				end if;
			end;
		