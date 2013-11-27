
		IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].sub_invoice_subreport'))
    EXEC dbo.sp_executesql @statement = N'      
	    create view sub_invoice_subreport as SELECT * FROM t_rpt_Invoice			
    '
	   