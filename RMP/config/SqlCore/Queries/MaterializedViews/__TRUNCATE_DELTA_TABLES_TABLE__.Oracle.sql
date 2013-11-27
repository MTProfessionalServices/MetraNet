
			begin
				if table_exists('%%DELTA_INSERT_TABLE_NAME%%') then
					execute immediate ('truncate table %%DELTA_INSERT_TABLE_NAME%%');
				end if;
				if table_exists('%%DELTA_DELETE_TABLE_NAME%%') then
					execute immediate ('truncate table %%DELTA_DELETE_TABLE_NAME%%');
				end if;
			end;
		