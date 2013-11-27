
 	INSERT INTO t_rpt_Invoice
	SELECT
			Invoice.id_invoice InvoiceID,
			Invoice.invoice_string InvoiceString,
			Invoice.id_acc AccountID,

			ISNULL(PayerContact.c_FirstName + N' ', N'') +
			ISNULL(PayerContact.c_MiddleInitial + N' ', N'') +
			ISNULL(PayerContact.c_LastName, N'') Name,

			Invoice.id_interval IntervalID,
	
			ISNULL(PayerContact.c_Company, N'') Company,
			ISNULL(PayerContact.c_Address1, N'') Address1,
			ISNULL(PayerContact.c_Address2, N'') Address2,
			ISNULL(PayerContact.c_Address3, N'') Address3,
			ISNULL(PayerContact.c_City, N'') City,
			ISNULL(PayerContact.c_Zip, N'') Zip,
			ISNULL(descCountry.tx_desc, N'') Country,
	
			Invoice.invoice_date InvoiceDate,
			Invoice.invoice_due_date InvoiceDueDate,
	
			Invoice.current_balance - Invoice.invoice_amount - 
			Invoice.postbill_adj_ttl_amt - Invoice.ar_adj_ttl_amt -
			Invoice.payment_ttl_amt PreviousBalance,

			Invoice.payment_ttl_amt Payments,

			Invoice.postbill_adj_ttl_amt + Invoice.ar_adj_ttl_amt TotalPostBillAdjustments, 
			Invoice.current_balance - Invoice.invoice_amount BalanceForward, 
			Invoice.invoice_amount - Invoice.tax_ttl_amt CurrentPreTaxAmount, 
			Invoice.tax_ttl_amt CurrentTaxAmount,
			Invoice.invoice_amount CurrentAmount,
			Invoice.current_balance CurrentBalance,
			
			/*0 CurrentTotalConfCharge,*/
 			/*SUM(CASE WHEN (acc.id_view = 4) THEN (ISNULL(acc.Amount, 0.0)) ELSE 0 END) CurrentTotalConfCharge, */
			SUM(CASE WHEN (edView.nm_enum_data ='metratech.com/audioconfcall') THEN (ISNULL(acc.Amount, 0.0)) ELSE 0 END) CurrentTotalConfCharge,

			/*0 CurrentTotalDiscounts,*/
			/*SUM(CASE WHEN (acc.id_view in (13, 14, 19, 20)) THEN (ISNULL(acc.Amount, 0.0)) ELSE 0 END) CurrentTotalDiscounts, */
			SUM(CASE WHEN (edView.nm_enum_data = 'metratech.com/flatdiscount') THEN (ISNULL(acc.Amount, 0.0))
			         WHEN (edView.nm_enum_data = 'metratech.com/flatdiscount_nocond') THEN (ISNULL(acc.Amount, 0.0))
				 WHEN (edView.nm_enum_data = 'metratech.com/percentdiscount') THEN  (ISNULL(acc.Amount, 0.0))
				 WHEN (edView.nm_enum_data = 'metratech.com/percentdiscount_nocond') THEN (ISNULL(acc.Amount, 0.0))
			    ELSE 0 END) CurrentTotalDiscounts, 

			/*0 CurrentTotalRecurringCharge, */
 			/*SUM(CASE WHEN (acc.id_view in (15, 23)) THEN (ISNULL(acc.Amount, 0.0)) ELSE 0 END) CurrentTotalRecurringCharge, */
			SUM(CASE WHEN (edView.nm_enum_data = 'metratech.com/flatrecurringcharge') THEN (ISNULL(acc.Amount, 0.0))
			         WHEN (edView.nm_enum_data = 'metratech.com/udrecurringcharge') THEN (ISNULL(acc.Amount, 0.0))
			    ELSE 0 END) CurrentTotalRecurringCharge, 

			/*0 CurrentTotalOtherCharge,*/
 			/*SUM(CASE WHEN (acc.id_view not in(4, 13, 14, 15, 19, 20, 23)) THEN (ISNULL(acc.Amount, 0.0)) ELSE 0 END) CurrentTotalOtherCharge, */
			SUM(CASE WHEN ( (edView.nm_enum_data != 'metratech.com/flatdiscount') AND
					(edView.nm_enum_data != 'metratech.com/flatdiscount_nocond') AND
					(edView.nm_enum_data !='metratech.com/percentdiscount') AND
					(edView.nm_enum_data !='metratech.com/percentdiscount_nocond') AND
					(edView.nm_enum_data !='metratech.com/flatrecurringcharge') AND
					(edView.nm_enum_data !='metratech.com/udrecurringcharge') AND
					(edView.nm_enum_data !='metratech.com/audioconfcall') AND
					(edView.nm_enum_data != 'metratech.com/Payment') AND
					(edView.nm_enum_data != 'metratech.com/ARAdjustment'))
					 THEN (ISNULL(acc.Amount, 0.0))
			        ELSE 0 END) CurrentTotalOtherCharge, 
			Invoice.invoice_amount - Invoice.tax_ttl_amt -
				SUM(CASE WHEN ( (edView.nm_enum_data != 'metratech.com/Payment') AND
					(edView.nm_enum_data != 'metratech.com/ARAdjustment'))
					 THEN (ISNULL(acc.Amount, 0.0))
			            ELSE 0 END) TotalPrebillAdjustments,
			Invoice.invoice_currency,
			lang.tx_lang_code, 
			edInvoiceMethod.nm_enum_data
	
		FROM %%NETMETER_DB_NAME%%..t_invoice Invoice
		LEFT OUTER JOIN %%NETMETER_DB_NAME%%..t_acc_usage acc
			on Invoice.id_acc = acc.id_acc
			and Invoice.id_interval = acc.id_usage_interval
		LEFT OUTER JOIN %%NETMETER_DB_NAME%%..t_view_hierarchy vh
			on acc.id_view = vh.id_view
			and vh.id_view = vh.id_view_parent
		LEFT OUTER JOIN %%NETMETER_DB_NAME%%..t_enum_data edView
			on vh.id_view = edView.id_enum_data
		LEFT OUTER JOIN
			%%NETMETER_DB_NAME%%..t_av_contact PayerContact
			on Invoice.id_acc = PayerContact.id_acc
		LEFT OUTER JOIN
			%%NETMETER_DB_NAME%%..t_enum_data edContactType
			on PayerContact.c_contacttype = edContactType.id_enum_data
			and edContactType.nm_enum_data = 'metratech.com/accountcreation/contacttype/bill-to'	
		INNER JOIN %%NETMETER_DB_NAME%%..t_av_internal internal
			on Invoice.id_acc = internal.id_acc
		INNER JOIN %%NETMETER_DB_NAME%%..t_enum_data edInvoiceMethod
			on internal.c_InvoiceMethod = edInvoiceMethod.id_enum_data
		INNER JOIN %%NETMETER_DB_NAME%%..t_enum_data edLanguage
			on internal.c_Language = edLanguage.id_enum_data
		INNER JOIN %%NETMETER_DB_NAME%%..t_language lang
			on 'Global/LanguageCode/' + lang.tx_lang_code = edLanguage.nm_enum_data
		LEFT OUTER JOIN %%NETMETER_DB_NAME%%..t_description descCountry
			on PayerContact.c_country = descCountry.id_desc
			and descCountry.id_lang_code = lang.id_lang_code
	where
			Invoice.id_interval = %%ID_INTERVAL%%
			/*and Invoice.invoice_amount <> 0	*/
			and acc.id_parent_sess is NULL
			and edInvoiceMethod.nm_enum_data <> 'metratech.com/accountcreation/InvoiceMethod/None'

	group by Invoice.id_invoice, Invoice.invoice_string, Invoice.id_acc, Invoice.id_interval, PayerContact.c_firstname,
		PayerContact.c_middleinitial, PayerContact.c_lastname, PayerContact.c_company, PayerContact.c_address1,
		PayerContact.c_address2, PayerContact.c_address3, PayerContact.c_city, PayerContact.c_zip,
		descCountry.tx_desc, Invoice.invoice_date, Invoice.invoice_due_date, Invoice.current_balance,
		Invoice.invoice_amount, Invoice.postbill_adj_ttl_amt, Invoice.ar_adj_ttl_amt, Invoice.payment_ttl_amt,
		Invoice.tax_ttl_amt, Invoice.invoice_currency, lang.tx_lang_code, edInvoiceMethod.nm_enum_data
	   