
        /* This is essentially __GET_INVOICES_TO_EXPORT__ with the additional columns for TaxAmount and
        SalesAmount needed to summarize Tax Detail information returned by __INVOICE_TAX_DETAILS_FOR_EXTERNAL_AR_SYSTEM__ */
        /* Note that when customizing, both this query and __INVOICE_TAX_DETAILS_FOR_EXTERNAL_AR_SYSTEM__ need:
        1) to return/summarize the same data
        2) to return results sorted on InvoiceID the same way
        */
		SELECT 
          '%%ID_PREFIX%%' + CONVERT(varchar, inv.id_invoice_num) as InvoiceID,
          '%%BATCH_ID%%' as BatchID,
          inv.invoice_string as Description, 
          inv.invoice_date as InvoiceDate,
          inv.invoice_due_date as DueDate,
          am.ExtAccount as ExtAccountID,
          /*am.ExtNamespace as ExtNamespace,*/
          inv.invoice_amount as InvoiceAmount,
          inv.tax_ttl_amt as TaxAmount,
          inv.invoice_amount - inv.tax_ttl_amt as SalesAmount,
          inv.invoice_currency as Currency
        FROM t_invoice inv 
        INNER JOIN vw_ar_acc_mapper am ON am.id_acc = inv.id_acc and 
                                         am.ExtNamespace = '%%NAME_SPACE%%'                                         
        INNER JOIN t_billgroup_member bgm ON inv.id_acc = bgm.id_acc
        INNER JOIN t_billgroup bg ON bg.id_billgroup = bgm.id_billgroup
			                              and inv.id_interval=bg.id_usage_interval
        WHERE bg.id_billgroup = %%ID_BILLGROUP%%  
        AND inv.invoice_amount >= 0  
        ORDER BY InvoiceID ASC           
        