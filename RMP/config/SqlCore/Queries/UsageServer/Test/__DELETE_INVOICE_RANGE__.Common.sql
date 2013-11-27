
/* ===========================================================
Delete from t_invoice_range for the given interval/billing group 
============================================================== */
DELETE FROM t_invoice_range
WHERE id_interval = %%ID_INTERVAL%% AND
      id_billgroup IN (%%BILLGROUP_IDS%%)
