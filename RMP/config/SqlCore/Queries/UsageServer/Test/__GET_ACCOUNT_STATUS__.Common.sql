
/* ===========================================================
Get the account status for the given accounts and interval.
============================================================== */
SELECT tx_status
FROM t_acc_usage_interval
WHERE id_acc IN (%%ACCOUNT_LIST%%) AND
      id_usage_interval = %%ID_INTERVAL%%
GROUP BY tx_status
 