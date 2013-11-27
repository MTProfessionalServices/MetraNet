
		CREATE OR REPLACE VIEW payee_subreport (
		payeename,
		conferences,
		charges,
		othercharges,
		totalcharges,
		invoiceid)
		AS
		SELECT t_rpt_Parent_Summary.PayeeName, 
		count(t_rpt_Parent_Summary.ItemDescription) Conferences,
		sum(t_rpt_Parent_Summary.Amount) Charges,
		sum(ReservationCharges) + sum(CancelCharges) + sum(OverUsedPortCharges) + sum(UnUsedPortCharges) + sum(Adjustments) OtherCharges,
		sum(t_rpt_Parent_Summary.Amount) + sum(ReservationCharges) + sum(CancelCharges) + sum(OverUsedPortCharges) + sum(UnUsedPortCharges) + sum(Adjustments) TotalCharges,
		t_rpt_Invoice.invoiceid
		FROM t_rpt_Parent_Summary t_rpt_Parent_Summary INNER JOIN 
		t_rpt_Invoice t_rpt_Invoice ON t_rpt_Parent_Summary.InvoiceID=t_rpt_Invoice.InvoiceID
		WHERE t_rpt_Parent_Summary.ItemDescription= 'Audio Conferencing'
		group by t_rpt_Invoice.invoiceid, payeename
	