
 		IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'%%TABLE_NAME%%') 
			and OBJECTPROPERTY(id, N'IsUserTable') = 1) DROP TABLE %%TABLE_NAME%%