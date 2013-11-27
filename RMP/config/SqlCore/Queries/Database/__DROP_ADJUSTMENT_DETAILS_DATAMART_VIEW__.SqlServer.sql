
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VW_ADJUSTMENT_DETAILS_DATAMART]') and OBJECTPROPERTY(id, N'IsView') = 1)
		drop view [dbo].[VW_ADJUSTMENT_DETAILS_DATAMART]
    