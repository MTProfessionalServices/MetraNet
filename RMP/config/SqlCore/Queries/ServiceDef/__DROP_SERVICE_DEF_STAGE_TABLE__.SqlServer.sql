
		  IF EXISTS (SELECT * FROM SYSOBJECTS WHERE id = object_id(
		  'dbo.%%SDEF_NAME%%'))
		  drop table dbo.%%SDEF_NAME%%
	  