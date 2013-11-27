
/* ===========================================================
Delete from t_invoice for the given interval/accounts 
============================================================== */
DELETE FROM t_invoice
WHERE id_interval = %%ID_INTERVAL%% AND
      id_acc IN (%%ACCOUNT_IDS%%)
