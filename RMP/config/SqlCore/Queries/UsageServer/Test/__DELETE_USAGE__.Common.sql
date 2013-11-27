
/* ===========================================================
Delete usage for the given accounts and interval.
============================================================== */
DELETE
FROM t_acc_usage
WHERE id_acc IN (%%ACCOUNT_LIST%%) AND
      id_usage_interval = %%ID_INTERVAL%%
 