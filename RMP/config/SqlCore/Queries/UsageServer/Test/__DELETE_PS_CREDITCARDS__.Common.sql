
/* ===========================================================
Delete the given accounts from t_ps_creditcard
============================================================== */
DELETE FROM t_ps_creditcard
WHERE id_acc IN (%%ACCOUNT_IDS%%)
