
		IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].sub_invoice_subreport'))
			drop view [dbo].[sub_invoice_subreport]
	   