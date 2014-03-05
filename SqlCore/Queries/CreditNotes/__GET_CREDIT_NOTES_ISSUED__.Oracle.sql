SELECT
	CN.c_CreditNoteID AS CreditNoteID,
	(TEMPLATE.c_CreditNotePrefix || CN.c_CreditNoteID) AS CreditNoteIdentifier,
	(SUBSCRIBER.c_FirstName || ' '|| SUBSCRIBER.c_LastName) AS AccountName,
	(CREATOR.c_FirstName || ' ' || CREATOR.c_LastName) AS CreatedBy,
	CN.c_CreationDate AS CreatedDate,
	ABS(AMOUNTS.TotalAmount) AS Amount,
	ABS(AMOUNTS.TotalTaxAmount) AS TaxAmount,
	ABS(AMOUNTS.TotalAmount) + ABS(AMOUNTS.TotalTaxAmount) AS TotalAmount,
	INTERNAL.c_Currency AS Currency,
	CNPDF.c_Status AS CreditNotePDFStatus,
	INTERNAL.id_acc AS AccountID
FROM t_be_cor_cre_creditnote CN
INNER JOIN (SELECT
							CN.c_CreditNote_Id,
							SUM(NVL(USAGE.amount,0)) + SUM(NVL(ADJUSTMENTS.AdjustmentAmount,0)) AS TotalAmount,
							SUM(NVL(USAGE.tax_federal, 0)) + SUM(NVL(USAGE.tax_state, 0)) + SUM(NVL(USAGE.tax_county, 0)) + SUM(NVL(USAGE.tax_local, 0)) + SUM(NVL(USAGE.tax_other, 0)) +
							SUM(NVL(ADJUSTMENTS.aj_tax_federal, 0)) + SUM(NVL(ADJUSTMENTS.aj_tax_state, 0)) + SUM(NVL(ADJUSTMENTS.aj_tax_county, 0)) + SUM(NVL(ADJUSTMENTS.aj_tax_local, 0)) + SUM(NVL(ADJUSTMENTS.aj_tax_other, 0)) AS TotalTaxAmount
						FROM t_be_cor_cre_creditnote CN 
						INNER JOIN t_be_cor_cre_creditnoteitem CNI ON CNI.c_CreditNote_Id = CN.c_CreditNote_Id
						LEFT JOIN t_acc_usage USAGE ON USAGE.id_sess = CNI.c_SessionID
						LEFT JOIN t_adjustment_transaction ADJUSTMENTS ON ADJUSTMENTS.id_adj_trx = CNI.c_AdjustmentTransactionID
						GROUP BY CN.c_CreditNote_Id) AMOUNTS ON cn.c_CreditNote_Id = AMOUNTS.c_CreditNote_Id
INNER JOIN t_be_cor_cre_creditnotetmpl TEMPLATE ON TEMPLATE.c_CreditNoteTmpl_Id = CN.c_CreditNoteTmpl_Id
LEFT JOIN t_av_Contact SUBSCRIBER ON SUBSCRIBER.id_acc = CN.c_AccountID 
LEFT JOIN t_av_Contact CREATOR ON CREATOR.id_acc = CN.c_CreatorID
LEFT JOIN t_av_Internal INTERNAL ON INTERNAL.id_acc = CN.c_AccountID
INNER JOIN t_be_cor_cre_creditnotepdf CNPDF on CNPDF.c_CreditNote_Id = CN.c_CreditNote_Id
WHERE CN.c_AccountID = :AccountID OR :AccountID = -1

