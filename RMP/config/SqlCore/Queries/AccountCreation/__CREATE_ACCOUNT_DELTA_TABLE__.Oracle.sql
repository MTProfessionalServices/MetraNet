
		begin
			if not table_exists('%%TABLE_NAME%%') then
				exec_ddl ('create table %%TABLE_NAME%%
							(id_dm_acc number(10) NOT NULL,
							id_acc number(10) NULL,
							vt_start date NULL,
							vt_end date NULL)');
			end if;
		end;
		