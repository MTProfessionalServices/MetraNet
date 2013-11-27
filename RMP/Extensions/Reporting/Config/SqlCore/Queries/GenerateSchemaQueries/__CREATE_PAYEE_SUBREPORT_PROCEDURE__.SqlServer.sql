
		IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].payee_subreport'))
    EXEC dbo.sp_executesql @statement = N'  
  	  create view payee_subreport
				as
				SELECT "t_rpt_Parent_Summary"."PayeeName", 
				count("t_rpt_Parent_Summary"."ItemDescription") Conferences,
				sum("t_rpt_Parent_Summary"."Amount") Charges,
				sum(ReservationCharges) + sum(CancelCharges) + sum(OverUsedPortCharges) + sum(UnUsedPortCharges) + sum(Adjustments) as OtherCharges,
				sum("t_rpt_Parent_Summary"."Amount") + sum(ReservationCharges) + sum(CancelCharges) + sum(OverUsedPortCharges) + sum(UnUsedPortCharges) + sum(Adjustments) as TotalCharges,
				t_rpt_Invoice.invoiceid as invoiceid
				FROM   "t_rpt_Parent_Summary" "t_rpt_Parent_Summary" INNER JOIN 
				"t_rpt_Invoice" "t_rpt_Invoice" ON "t_rpt_Parent_Summary"."InvoiceID"="t_rpt_Invoice"."InvoiceID"
				WHERE  "t_rpt_Parent_Summary"."ItemDescription"=N''Audio Conferencing''
				group by t_rpt_Invoice.invoiceid, payeename
    '
 	   