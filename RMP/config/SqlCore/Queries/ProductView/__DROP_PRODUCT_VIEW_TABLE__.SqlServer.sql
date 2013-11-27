
			     IF EXISTS (SELECT * FROM SYSOBJECTS WHERE id = object_id(
			     'dbo.%%PRODUCT_VIEW_NAME%%')) DROP TABLE 
				 dbo.%%PRODUCT_VIEW_NAME%%
			