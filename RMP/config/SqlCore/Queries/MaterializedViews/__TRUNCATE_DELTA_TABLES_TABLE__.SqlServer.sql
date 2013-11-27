
			BEGIN
	        IF object_id('%%DELTA_INSERT_TABLE_NAME%%') is not null
            TRUNCATE TABLE %%DELTA_INSERT_TABLE_NAME%%
	        IF object_id('%%DELTA_DELETE_TABLE_NAME%%') is not null
            TRUNCATE TABLE %%DELTA_DELETE_TABLE_NAME%%
			END
		