
 		if NOT EXISTS (select name from sysobjects where name = 't_rpt_Parent_Summary' and xtype = 'U')
		CREATE TABLE t_rpt_Parent_Summary (
			InvoiceID int NOT NULL,
			PayeeIDAcc int NOT NULL,
			PayeeName nvarchar(100) NULL,
			SessionID int NOT NULL,
			ConferenceID nvarchar(255) NULL,
			ConfDate datetime NULL,
			Duration numeric (22,10) NULL,
			ConfName nvarchar(30) NULL,
			COnfSubject nvarchar(50) NULL,
			TotalConnections int NULL,
			Amount numeric (22,10) NULL,
			ItemDescription nvarchar(255) NULL,
			ReservationCharges numeric (22,10) NULL,
			CancelCharges numeric (22,10) NULL,
			OverUsedPortCharges numeric (22,10) NULL,
			UnUsedPortCharges numeric (22,10) NULL,
			Adjustments numeric (22,10) NULL
			/*CONSTRAINT PK_t_rpt_parent_summary PRIMARY KEY CLUSTERED (SessionID),*/
			/*CONSTRAINT FK_t_Parent_Summary FOREIGN KEY (INVOICEID) References t_rpt_Invoice(InvoiceID)*/
			)
	   