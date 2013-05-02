
			     IF EXISTS (SELECT * FROM SYSOBJECTS WHERE id = object_id(
			     'dbo.%%TABLE_NAME%%')) DROP TABLE 
				 dbo.%%TABLE_NAME%%
			