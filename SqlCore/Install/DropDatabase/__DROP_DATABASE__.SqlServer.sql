IF EXISTS (SELECT * FROM sysdatabases where name = '%%DATABASE_NAME%%') DROP DATABASE %%DATABASE_NAME%%
		 	