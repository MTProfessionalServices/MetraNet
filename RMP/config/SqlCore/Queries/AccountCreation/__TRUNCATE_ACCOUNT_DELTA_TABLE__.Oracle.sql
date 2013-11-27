
		begin
			if table_exists('%%TABLE_NAME%%') then
				execute immediate 'delete from %%TABLE_NAME%%';
			end if;
		end;
		