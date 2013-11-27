
			     IF EXISTS (SELECT * FROM SYSOBJECTS WHERE id = object_id(
			     'dbo.%%ACCOUNT_VIEW_NAME%%')) DROP TABLE 
				 dbo.%%ACCOUNT_VIEW_NAME%%
			