
	   begin
 			INSERT INTO t_rpt_Invoice
			SELECT
			Invoice.id_invoice InvoiceID,
			Invoice.invoice_string InvoiceString,
			Invoice.id_acc AccountID,
			nvl(PayerContact.c_FirstName || ' ', '') ||
			nvl(PayerContact.c_MiddleInitial || ' ', '') ||
			nvl(PayerContact.c_LastName, '') Fullname,

			Invoice.id_interval IntervalID,
	
			nvl(PayerContact.c_Company, '') Company,
			nvl(PayerContact.c_Address1, '') Address1,
			nvl(PayerContact.c_Address2, '') Address2,
			nvl(PayerContact.c_Address3, '') Address3,
			nvl(PayerContact.c_City, '') City,
			nvl(PayerContact.c_Zip, '') Zip,
			nvl(descCountry.tx_desc, '') Country,
	
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
			
			SUM(CASE WHEN (edView.nm_enum_data ='metratech.com/audioconfcall') THEN (nvl(acc.Amount, 0.0)) ELSE 0 END) CurrentTotalConfCharge,

			SUM(CASE WHEN (edView.nm_enum_data = 'metratech.com/flatdiscount') THEN (nvl(acc.Amount, 0.0))
			         WHEN (edView.nm_enum_data = 'metratech.com/flatdiscount_nocond') THEN (nvl(acc.Amount, 0.0))
				     WHEN (edView.nm_enum_data = 'metratech.com/percentdiscount') THEN  (nvl(acc.Amount, 0.0))
				     WHEN (edView.nm_enum_data = 'metratech.com/percentdiscount_nocond') THEN (nvl(acc.Amount, 0.0))
			    ELSE 0 END) CurrentTotalDiscounts, 

			SUM(CASE WHEN (edView.nm_enum_data = 'metratech.com/flatrecurringcharge') THEN (nvl(acc.Amount, 0.0))
			         WHEN (edView.nm_enum_data = 'metratech.com/udrecurringcharge') THEN (nvl(acc.Amount, 0.0))
			    ELSE 0 END) CurrentTotalRecurringCharge, 

			SUM(CASE WHEN ( (edView.nm_enum_data != 'metratech.com/flatdiscount') AND
					(edView.nm_enum_data != 'metratech.com/flatdiscount_nocond') AND
					(edView.nm_enum_data !='metratech.com/percentdiscount') AND
					(edView.nm_enum_data !='metratech.com/percentdiscount_nocond') AND
					(edView.nm_enum_data !='metratech.com/flatrecurringcharge') AND
					(edView.nm_enum_data !='metratech.com/udrecurringcharge') AND
					(edView.nm_enum_data !='metratech.com/audioconfcall') AND
					(edView.nm_enum_data != 'metratech.com/Payment') AND
					(edView.nm_enum_data != 'metratech.com/ARAdjustment'))
					 THEN (nvl(acc.Amount, 0.0))
		       ELSE 0 END) CurrentTotalOtherCharge, 
	
			Invoice.invoice_amount - Invoice.tax_ttl_amt -
				SUM(CASE WHEN ( (edView.nm_enum_data != 'metratech.com/Payment') AND
					(edView.nm_enum_data != 'metratech.com/ARAdjustment'))
					 THEN (nvl(acc.Amount, 0.0))
			            ELSE 0 END) TotalPrebillAdjustments,
			Invoice.invoice_currency,
			lang.tx_lang_code, 
			edInvoiceMethod.nm_enum_data
	
		FROM %%NETMETER_DB_NAME%%.t_invoice Invoice
		INNER JOIN %%NETMETER_DB_NAME%%.t_billgroup_member bgm
			on Invoice.id_acc = bgm.id_acc and bgm.id_billgroup = %%ID_BILLGROUP%% 
		INNER JOIN %%NETMETER_DB_NAME%%.t_billgroup bg
			on Invoice.id_interval = bg.id_usage_interval
			and bg.id_billgroup = %%ID_BILLGROUP%% 
		LEFT OUTER JOIN %%NETMETER_DB_NAME%%.t_acc_usage acc
			on Invoice.id_acc = acc.id_acc
			and Invoice.id_interval = acc.id_usage_interval
		LEFT OUTER JOIN %%NETMETER_DB_NAME%%.t_view_hierarchy vh
			on acc.id_view = vh.id_view
			and vh.id_view = vh.id_view_parent
		LEFT OUTER JOIN %%NETMETER_DB_NAME%%.t_enum_data edView
			on vh.id_view = edView.id_enum_data
		LEFT OUTER JOIN
			%%NETMETER_DB_NAME%%.t_av_contact PayerContact
			on Invoice.id_acc = PayerContact.id_acc
		LEFT OUTER JOIN
			%%NETMETER_DB_NAME%%.t_enum_data edContactType
			on PayerContact.c_contacttype = edContactType.id_enum_data
			and edContactType.nm_enum_data = 'metratech.com/accountcreation/contacttype/bill-to'	
		INNER JOIN %%NETMETER_DB_NAME%%.t_av_internal internal
			on Invoice.id_acc = internal.id_acc
		INNER JOIN %%NETMETER_DB_NAME%%.t_enum_data edInvoiceMethod
			on internal.c_InvoiceMethod = edInvoiceMethod.id_enum_data
		INNER JOIN %%NETMETER_DB_NAME%%.t_enum_data edLanguage
			on internal.c_Language = edLanguage.id_enum_data
		INNER JOIN %%NETMETER_DB_NAME%%.t_language lang
			on 'Global/LanguageCode/' || UPPER(lang.tx_lang_code) = edLanguage.nm_enum_data
		LEFT OUTER JOIN %%NETMETER_DB_NAME%%.t_description descCountry
			on PayerContact.c_country = descCountry.id_desc
			and descCountry.id_lang_code = lang.id_lang_code
		where
			acc.id_parent_sess is NULL
			and edInvoiceMethod.nm_enum_data <> 'metratech.com/accountcreation/InvoiceMethod/None'

	group by Invoice.id_invoice, Invoice.invoice_string, Invoice.id_acc, Invoice.id_interval, PayerContact.c_firstname,
		PayerContact.c_middleinitial, PayerContact.c_lastname, PayerContact.c_company, PayerContact.c_address1,
		PayerContact.c_address2, PayerContact.c_address3, PayerContact.c_city, PayerContact.c_zip,
		descCountry.tx_desc, Invoice.invoice_date, Invoice.invoice_due_date, Invoice.current_balance,
		Invoice.invoice_amount, Invoice.postbill_adj_ttl_amt, Invoice.ar_adj_ttl_amt, Invoice.payment_ttl_amt,
		Invoice.tax_ttl_amt, Invoice.invoice_currency, lang.tx_lang_code, edInvoiceMethod.nm_enum_data;
	end;
	   