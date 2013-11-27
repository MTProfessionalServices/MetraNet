
		if object_id('%%DELTA_TABLE_NAME%%') is null begin
			select * into %%DELTA_TABLE_NAME%% from %%TABLE_NAME%% where 0=1
		end
		else begin
			truncate table %%DELTA_TABLE_NAME%%
		end
		