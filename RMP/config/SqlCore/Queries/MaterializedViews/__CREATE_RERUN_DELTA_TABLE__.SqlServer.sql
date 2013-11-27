
			if object_id('%%DELTA_TABLE_NAME%%') is null
			begin
				select * into %%DELTA_TABLE_NAME%% from %%BASE_TABLE_NAME%% where 0=1
			end
		