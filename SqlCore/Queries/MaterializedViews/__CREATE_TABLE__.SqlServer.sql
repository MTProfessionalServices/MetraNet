
			if OBJECT_ID('%%TABLE_NAME%%') is null
			BEGIN
				CREATE TABLE %%TABLE_NAME%% %%DDL%%
			END
		