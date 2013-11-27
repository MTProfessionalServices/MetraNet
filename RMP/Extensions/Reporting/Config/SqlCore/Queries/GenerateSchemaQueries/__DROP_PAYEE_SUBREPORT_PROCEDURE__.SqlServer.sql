
		IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].payee_subreport'))
			drop view [dbo].[payee_subreport]
	   