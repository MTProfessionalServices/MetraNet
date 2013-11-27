
	    begin
 		if NOT table_exists('t_rpt_Parent_Summary') then
 		execute immediate '
		CREATE TABLE t_rpt_Parent_Summary (
			InvoiceID number(10) NOT NULL,
			PayeeIDAcc number(10) NOT NULL,
			PayeeName nvarchar2(100) NULL,
			SessionID number(10) NOT NULL,
			ConferenceID nvarchar2(255) NULL,
			ConfDate date NULL,
			Duration number(22,10) NULL,
			ConfName nvarchar2(30) NULL,
			COnfSubject nvarchar2(50) NULL,
			TotalConnections number(10) NULL,
			Amount numeric (22,10) NULL,
			ItemDescription nvarchar2(255) NULL,
			ReservationCharges numeric (22,10) NULL,
			CancelCharges numeric (22,10) NULL,
			OverUsedPortCharges numeric (22,10) NULL,
			UnUsedPortCharges numeric (22,10) NULL,
			Adjustments numeric (22,10) NULL
			)';
			end if;
		end;
	   