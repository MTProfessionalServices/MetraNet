
			if not table_exists('%%TABLE_NAME%%') then
				/* execute immediate ('create table %%TABLE_NAME%% %%DDL%%'); */
				exec_ddl ('create table %%TABLE_NAME%% %%DDL%%');
			end if;
		