
		begin 
     		if not table_exists('%%DELTA_TABLE_NAME%%') then 
				exec_ddl('create table %%DELTA_TABLE_NAME%% as select * from %%TABLE_NAME%% where 0=1');
        end if;
			
			execute immediate 'insert into %%DELTA_TABLE_NAME%% select * from %%TABLE_NAME%% %%WHERE_CLAUSE%%';
		end;
		