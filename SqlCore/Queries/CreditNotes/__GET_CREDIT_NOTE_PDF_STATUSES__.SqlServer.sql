SELECT 
	ISNULL(td.tx_desc, REPLACE(ed.nm_enum_data, 'MetraTech.MetraNet.CreditNotes/CreditNotePDFStatus/', '')) AS 'localized_pdf_status'
FROM t_enum_data ed 
LEFT JOIN t_description td ON ed.id_enum_data = td.id_desc AND td.id_lang_code = @LangID 
WHERE ed.nm_enum_data LIKE 'MetraTech.MetraNet.CreditNotes/CreditNotePDFStatus/%'