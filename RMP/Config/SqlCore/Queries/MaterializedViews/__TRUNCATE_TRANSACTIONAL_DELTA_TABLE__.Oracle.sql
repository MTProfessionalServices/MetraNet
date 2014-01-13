
			begin
				if table_exists('%%DELTA_TABLE_NAME%%') then
					delete from %%DELTA_TABLE_NAME%%;
				end if;
			end;
		