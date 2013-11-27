
        SELECT
          inv.id_invoice as id_invoice,
          inv.id_invoice_num as id_invoice_num,
          inv.invoice_string as invoice_string,
          inv.invoice_date as invoice_date,
          inv.invoice_due_date as invoice_due_date,
          inv.id_interval as id_interval,
          interv.dt_start as interval_start,
          interv.dt_end as interval_end,
          inv.invoice_currency as currency,
          inv.id_payer as id_payer,
          inv.current_balance - inv.invoice_amount - inv.ar_adj_ttl_amt - inv.postbill_adj_ttl_amt - inv.payment_ttl_amt as previous_balance,
          inv.current_balance - inv.invoice_amount as balance_forward,
          dbo.mtstartofday(inv.balance_forward_date) as balance_forward_date,
          inv.current_balance as current_balance
        FROM
          t_invoice inv
          JOIN t_pc_interval interv ON inv.id_interval = interv.id_interval
        WHERE
          inv.id_interval = %%ID_INTERVAL%%
          AND inv.id_acc = %%ID_ACC%%
        