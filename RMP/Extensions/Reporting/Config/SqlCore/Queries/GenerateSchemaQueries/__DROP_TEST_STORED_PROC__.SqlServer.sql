
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestStoredProc]') AND type in (N'P', N'PC'))
		drop procedure TestStoredProc
	 