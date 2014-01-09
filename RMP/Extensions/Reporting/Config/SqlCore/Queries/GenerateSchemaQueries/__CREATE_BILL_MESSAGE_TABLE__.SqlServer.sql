
 		   if NOT EXISTS (select name from sysobjects where name = 't_rpt_bill_messages' and xtype = 'U')
 		   CREATE TABLE t_rpt_bill_messages (
			InvoiceID int NOT NULL,
			InvoiceString nvarchar(50) NOT NULL,
			AccountID int NOT NULL,
			IntervalID int NOT NULL,
			MessageType int NOT NULL,
			MessageText nvarchar(2000) NOT NULL,
			MessageFormat nvarchar(20) NULL
			)
			