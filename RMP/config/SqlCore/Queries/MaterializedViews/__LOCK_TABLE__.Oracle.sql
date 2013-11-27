
			if table_exists('%%TABLE_NAME%%') then
				execute immediate('lock table %%TABLE_NAME%% in exclusive mode');
			end if;
		