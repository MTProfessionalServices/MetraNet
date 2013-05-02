
			if object_id('%%TABLE_NAME%%') is not null
	        begin
				select 1 from %%TABLE_NAME%% with(tablockx) where 0=1 
			end
		