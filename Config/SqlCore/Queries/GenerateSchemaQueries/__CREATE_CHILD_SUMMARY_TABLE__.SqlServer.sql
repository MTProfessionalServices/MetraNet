
 		if NOT EXISTS (select name from sysobjects where name = 't_rpt_child_summary' and xtype = 'U')
		Create table t_rpt_child_summary(
 			InvoiceID int NOT NULL,
 			ParentSessID int NOT NULL,
			ChildSessID int NOT NULL,
 			ChildDesc nvarchar(100) NOT NULL,
 			Attendee nvarchar(510),
 			CallNumber nvarchar(76),
 			Type nvarchar(255),
 			Minutes numeric(22,10),
 			Charge  numeric(22,10)
			/*CONSTRAINT PK_t_rpt_child_summary PRIMARY KEY CLUSTERED (ChildSessID),*/
			/*CONSTRAINT FK_t_child_Summary FOREIGN KEY (INVOICEID) References t_rpt_Invoice(InvoiceID)*/
			)
	   