
	   begin
 		   if NOT table_exists('t_rpt_Invoice') then
 		   execute immediate '
 		   CREATE TABLE t_rpt_Invoice (
			InvoiceID number(10) NOT NULL,
			InvoiceString nvarchar2(50) NOT NULL,
			AccountID number(10) NOT NULL,
			Name nvarchar2(100) NOT NULL,
			IntervalID number(10) NOT NULL,
			Company nvarchar2(255) NULL,
			Address1 nvarchar2(100) NULL,
			Address2 nvarchar2(100) NULL,
			Address3 nvarchar2(100) NULL,
			City nvarchar2(30) NULL,
			Zip nvarchar2(40) NULL,
			Country nvarchar2(255) NULL,
			InvoiceDate date NULL,
			InvoiceDueDate date NULL,
			PreviousBalance number(22,10) NOT NULL,
			Payments number(22,10) NOT NULL,
			TotalPostBillAdjustments number(22,10) NOT NULL,
			BalanceForward number(22,10) NOT NULL,
			CurrentPreTaxAmount number(22,10) NOT NULL,
			CurrentTaxAmount number(22,10) NOT NULL,
			CurrentAmount number(22,10) NOT NULL,
			CurrentBalance number(22,10) NOT NULL,
			CurrentTotalConfCharge number(22,10) NOT NULL,
			CurrentTotalDiscounts number(22,10) NOT NULL,
			CurrentTotalRecurringCharge number(22,10) NOT NULL,
			CurrentTotalOtherCharge number(22,10) NOT NULL,
			TotalPreBillAdjustments number(22,10) NOT NULL,
			Currency nvarchar2(10) NULL,
			InvoiceLanguage nvarchar2(10) NOT NULL,
			InvoiceMethod nvarchar2(255) NULL
			)';
			end if;
		end;
	   