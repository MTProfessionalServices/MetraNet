
/* ===========================================================
Return the max id_billgroup from t_billgroup.
============================================================== */
SELECT CAST(COALESCE(MAX(id_billgroup), 0) AS INTEGER) ID_BILLGROUP
FROM t_billgroup
 