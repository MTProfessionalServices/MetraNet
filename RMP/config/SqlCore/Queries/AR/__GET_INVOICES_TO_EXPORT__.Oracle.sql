
        SELECT
          '%%ID_PREFIX%%' || inv.id_invoice_num as InvoiceID,
          '%%BATCH_ID%%' as BatchID,
          inv.invoice_string as Description, 
          inv.invoice_date as InvoiceDate,
          inv.invoice_due_date as DueDate,
          am.ExtAccount as ExtAccountID,
          /*am.ExtNamespace as ExtNamespace,*/
          inv.invoice_amount as InvoiceAmount,
          inv.invoice_currency as Currency
        FROM t_invoice inv
        INNER JOIN vw_ar_acc_mapper am ON am.id_acc = inv.id_acc and am.ExtNamespace = '%%NAME_SPACE%%'
		INNER JOIN t_billgroup_member bg ON inv.id_acc = bg.id_acc 
        WHERE bg.id_billgroup = %%ID_BILLGROUP%%
        AND inv.invoice_amount >= 0      
        