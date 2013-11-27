
			if object_id('%%DELTA_TABLE_NAME%%') is not null 
			begin
				truncate table %%DELTA_TABLE_NAME%%
			end
		