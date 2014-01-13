
		 if object_id('%%TABLE_NAME%%') is null
			CREATE TABLE %%TABLE_NAME%%
			 (id_dm_acc int NOT NULL,
			  id_acc int NULL,
			  vt_start datetime NULL,
			  vt_end datetime NULL) 
			