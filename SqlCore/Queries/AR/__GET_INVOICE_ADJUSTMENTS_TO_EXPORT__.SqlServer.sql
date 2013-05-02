
        SELECT
          '%%ID_PREFIX%%' + CONVERT(varchar, inv.id_invoice_num) as AdjustmentID,
          'Credit' as Type,
          '%%BATCH_ID%%' as BatchID,
          inv.invoice_string  as Description, 
          inv.invoice_date as AdjustmentDate,
          am.ExtAccount as ExtAccountID,
          - inv.invoice_amount as Amount,
          inv.invoice_currency as Currency
        FROM t_invoice inv
        INNER JOIN vw_ar_acc_mapper am ON am.id_acc = inv.id_acc and am.ExtNamespace = '%%NAME_SPACE%%'
		INNER JOIN t_billgroup_member bg ON inv.id_acc = bg.id_acc 
        WHERE bg.id_billgroup = %%ID_BILLGROUP%%
        AND inv.invoice_amount < 0
        