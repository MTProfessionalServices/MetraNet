
		if object_id('%%DELTA_TABLE_NAME%%') is null
		begin
			exec ('select * into %%DELTA_TABLE_NAME%% from %%TABLE_NAME%% %%WHERE_CLAUSE%%')
		end
		else begin
			exec ('insert into %%DELTA_TABLE_NAME%% select * from %%TABLE_NAME%% %%WHERE_CLAUSE%%')
		end
	  