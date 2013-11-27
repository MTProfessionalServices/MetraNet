
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReverseTestStoredProc]') AND type in (N'P', N'PC'))
		drop procedure ReverseTestStoredProc
	 