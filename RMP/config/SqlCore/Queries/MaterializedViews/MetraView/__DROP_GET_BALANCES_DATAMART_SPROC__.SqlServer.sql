
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetBalances_Datamart]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
		drop procedure [dbo].[GetBalances_Datamart]
    