SELECT
	CN.c_CreditNoteID AS CreditNoteID,
  CN.c_CreditNoteString AS CreditNoteString,
	(TEMPLATE.c_CreditNotePrefix || CN.c_CreditNoteID) AS CreditNoteIdentifier,
	(SUBSCRIBER.c_FirstName || ' '|| SUBSCRIBER.c_LastName) AS AccountName,
	(CREATOR.c_FirstName || ' ' || CREATOR.c_LastName) AS CreatedBy,
	CN.c_CreationDate AS CreatedDate,
	( -1 * AMOUNTS.TotalAmount) AS Amount,
	( -1 * AMOUNTS.TotalTaxAmount) AS TaxAmount,
	( -1 * (AMOUNTS.TotalAmount + AMOUNTS.TotalTaxAmount)) AS TotalAmount,
	INTERNAL.c_Currency AS Currency,
	CNPDF.c_Status AS CreditNotePDFStatus,
  CNPDF.c_StatusInformation AS CreditNotePDFStatusInformation,
	TEMPLATE.c_LanguageCode AS TemplateLanguageCode,
	TEMPLATE.c_TemplateName AS TemplateName,
	TEMPLATE.c_CreditNotePrefix AS CreditNotePrefix,
	CN.c_AccountID AS AccountID,
  NVL(eventnamedesc.tx_desc, CNPDF.c_Status) AS CreditNotePDFStatusLocalized
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
INNER JOIN t_be_cor_cre_creditnotepdf CNPDF on CNPDF.c_CreditNote_Id = CN.c_CreditNote_Id
LEFT JOIN t_av_Contact SUBSCRIBER ON SUBSCRIBER.id_acc = CN.c_AccountID 
LEFT JOIN t_av_Contact CREATOR ON CREATOR.id_acc = CN.c_CreatorID
LEFT JOIN t_av_Internal INTERNAL ON INTERNAL.id_acc = CN.c_AccountID
LEFT JOIN t_enum_data edata ON LOWER(edata.nm_enum_data) LIKE CONCAT('metratech.metranet.creditnotes/creditnotepdfstatus/', LOWER(CNPDF.c_Status))
LEFT JOIN t_description eventnamedesc ON eventnamedesc.id_desc = edata.id_enum_data AND eventnamedesc.id_lang_code = :LangID
WHERE CN.c_AccountID = :AccountID OR :AccountID = -1

