
CREATE PROCEDURE MTSP_INSERTINVOICE_DEFLTINVNUM
@invoice_date DATETIME
AS
BEGIN
SELECT
	tmp.id_acc,
	tmp.namespace,
	tins.invoice_prefix
	 + ISNULL(REPLICATE('0', tins.invoice_num_digits - LEN(RTRIM(CONVERT(nvarchar,tmp.tmp_seq + tins.id_invoice_num_last + 1 - 1)))),'')
	 + RTRIM(CONVERT(nvarchar,tmp_seq + tins.id_invoice_num_last + 1 - 1))
	 + tins.invoice_suffix,
	@invoice_date+tins.invoice_due_date_offset,
	tmp.tmp_seq + tins.id_invoice_num_last
FROM #tmp_all_accounts tmp
INNER JOIN t_invoice_namespace tins ON tins.namespace = tmp.namespace
END
		