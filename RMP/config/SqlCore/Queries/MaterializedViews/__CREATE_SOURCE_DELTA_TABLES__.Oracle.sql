
			begin
				if not table_exists('%%DELTA_INSERT_TABLE_NAME%%') then
					execute immediate ('create table %%DELTA_INSERT_TABLE_NAME%% %%DDL%%');
				end if;
				if not table_exists('%%DELTA_DELETE_TABLE_NAME%%') then
					execute immediate ('create table %%DELTA_DELETE_TABLE_NAME%% %%DDL%%');
				end if;
			end;
		