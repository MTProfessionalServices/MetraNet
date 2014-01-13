
        /* This query must:
           1) Return InvoiceID, ExtTaxIdentifier (in Great Plains, the TaxDetailId), TaxAmount, TaxDetailSalesAmount
           2) Return a row for each ExtTaxIdentifier (TaxDetailId) to be exported
           3) The total of all TaxAmounts returned from this query for a particular invoice must match the total returned
           by the __INVOICE_TAX_SUMMARY_FOR_EXTERNAL_AR_SYSTEM__ query for the same invoice
        */
        
		SELECT 
          '%%ID_PREFIX%%' + CONVERT(varchar, inv.id_invoice_num) as InvoiceID,
          'GPTD_FEDERAL' as ExtTaxIdentifier,
          (select sum({fn IFNULL((tax_federal), 0.0)}) from t_acc_usage au where au.id_usage_interval=bg.id_usage_interval and au.id_acc=inv.id_acc) as TaxAmount, 
           inv.invoice_amount-inv.tax_ttl_amt as TaxDetailSalesAmount
        FROM t_invoice inv 
        INNER JOIN vw_ar_acc_mapper am ON am.id_acc = inv.id_acc and am.ExtNamespace = '%%NAME_SPACE%%'                                         
        INNER JOIN t_billgroup_member bgm ON inv.id_acc = bgm.id_acc
        INNER JOIN t_billgroup bg ON bg.id_billgroup = bgm.id_billgroup and inv.id_interval=bg.id_usage_interval
        WHERE bg.id_billgroup = %%ID_BILLGROUP%%  
        AND inv.invoice_amount >= 0

UNION

	SELECT 
          '%%ID_PREFIX%%' + CONVERT(varchar, inv.id_invoice_num) as InvoiceID,
          'GPTD_STATE' as ExtTaxIdentifier,
          (select sum({fn IFNULL((tax_state), 0.0)}) from t_acc_usage au where au.id_usage_interval=bg.id_usage_interval and au.id_acc=inv.id_acc) as TaxAmount, 
           inv.invoice_amount-inv.tax_ttl_amt as TaxDetailSalesAmount
        FROM t_invoice inv 
        INNER JOIN vw_ar_acc_mapper am ON am.id_acc = inv.id_acc and am.ExtNamespace = '%%NAME_SPACE%%'                                         
        INNER JOIN t_billgroup_member bgm ON inv.id_acc = bgm.id_acc
        INNER JOIN t_billgroup bg ON bg.id_billgroup = bgm.id_billgroup and inv.id_interval=bg.id_usage_interval
        WHERE bg.id_billgroup = %%ID_BILLGROUP%%  
        AND inv.invoice_amount >= 0

UNION

	SELECT 
          '%%ID_PREFIX%%' + CONVERT(varchar, inv.id_invoice_num) as InvoiceID,
          'GPTD_COUNTY' as ExtTaxIdentifier,
          (select sum({fn IFNULL((tax_county), 0.0)}) from t_acc_usage au where au.id_usage_interval=bg.id_usage_interval and au.id_acc=inv.id_acc) as TaxAmount, 
           inv.invoice_amount-inv.tax_ttl_amt as TaxDetailSalesAmount
        FROM t_invoice inv 
        INNER JOIN vw_ar_acc_mapper am ON am.id_acc = inv.id_acc and am.ExtNamespace = '%%NAME_SPACE%%'                                         
        INNER JOIN t_billgroup_member bgm ON inv.id_acc = bgm.id_acc
        INNER JOIN t_billgroup bg ON bg.id_billgroup = bgm.id_billgroup and inv.id_interval=bg.id_usage_interval
        WHERE bg.id_billgroup = %%ID_BILLGROUP%%  
        AND inv.invoice_amount >= 0
        
UNION

	SELECT 
          '%%ID_PREFIX%%' + CONVERT(varchar, inv.id_invoice_num) as InvoiceID,
          'GPTD_LOCAL' as ExtTaxIdentifier,
          (select sum({fn IFNULL((tax_local), 0.0)}) from t_acc_usage au where au.id_usage_interval=bg.id_usage_interval and au.id_acc=inv.id_acc) as TaxAmount, 
           inv.invoice_amount-inv.tax_ttl_amt as TaxDetailSalesAmount
        FROM t_invoice inv 
        INNER JOIN vw_ar_acc_mapper am ON am.id_acc = inv.id_acc and am.ExtNamespace = '%%NAME_SPACE%%'                                         
        INNER JOIN t_billgroup_member bgm ON inv.id_acc = bgm.id_acc
        INNER JOIN t_billgroup bg ON bg.id_billgroup = bgm.id_billgroup and inv.id_interval=bg.id_usage_interval
        WHERE bg.id_billgroup = %%ID_BILLGROUP%%  
        AND inv.invoice_amount >= 0
        
 UNION

	SELECT 
          '%%ID_PREFIX%%' + CONVERT(varchar, inv.id_invoice_num) as InvoiceID,
          'GPTD_OTHER' as ExtTaxIdentifier,
          (select sum({fn IFNULL((tax_other), 0.0)}) from t_acc_usage au where au.id_usage_interval=bg.id_usage_interval and au.id_acc=inv.id_acc) as TaxAmount, 
           inv.invoice_amount-inv.tax_ttl_amt as TaxDetailSalesAmount
        FROM t_invoice inv 
        INNER JOIN vw_ar_acc_mapper am ON am.id_acc = inv.id_acc and am.ExtNamespace = '%%NAME_SPACE%%'                                         
        INNER JOIN t_billgroup_member bgm ON inv.id_acc = bgm.id_acc
        INNER JOIN t_billgroup bg ON bg.id_billgroup = bgm.id_billgroup and inv.id_interval=bg.id_usage_interval
        WHERE bg.id_billgroup = %%ID_BILLGROUP%%  
        AND inv.invoice_amount >= 0
        
 ORDER BY InvoiceID ASC
         