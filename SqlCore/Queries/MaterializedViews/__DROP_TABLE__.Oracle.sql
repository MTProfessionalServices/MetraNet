
			begin
				if table_exists('%%TABLE_NAME%%') then
					exec_ddl('DROP TABLE %%TABLE_NAME%%');
				end if;
			end;
		