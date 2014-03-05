/* For a given account, what are the invoices we want to show on Account 360*/
/* Should use %%ACCOUNT_ID%% */
/* TODO: Determine how much to reference; at moment select last 12 months?*/
        SELECT
		  inv.id_acc as id_acc,
		  ahn.hierarchyname as accountname,
          inv.id_payer as id_payer,
		  phn.hierarchyname as payername,
          inv.id_invoice as id_invoice,
		  inv.invoice_amount as invoice_amount,
          inv.id_invoice_num as id_invoice_num,
          inv.invoice_string as invoice_string,
          inv.invoice_date as invoice_date,
          inv.invoice_due_date as invoice_due_date,
          inv.id_interval as id_interval,
          interv.dt_start as interval_start,
          interv.dt_end as interval_end,
          inv.invoice_currency as currency,
          inv.current_balance - inv.invoice_amount - inv.ar_adj_ttl_amt - inv.postbill_adj_ttl_amt - inv.payment_ttl_amt as previous_balance,
          inv.current_balance - inv.invoice_amount as balance_forward,
          dbo.mtstartofday(inv.balance_forward_date) as balance_forward_date,
          inv.current_balance as current_balance
        FROM
          t_invoice inv
		  /* Hacked intervals not lining up
		            JOIN t_usage_interval interv ON inv.id_interval = interv.id_interval
		  Changed to left join for now*/
          LEFT JOIN t_usage_interval interv ON inv.id_interval = interv.id_interval
		  LEFT JOIN VW_HIERARCHYNAME ahn on inv.id_acc = ahn.id_acc
		  LEFT JOIN VW_HIERARCHYNAME phn on inv.id_payer = phn.id_acc
        WHERE
          inv.id_payer = %%ACCOUNT_ID%%