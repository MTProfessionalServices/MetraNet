
/* ===========================================================
Return the max id_materialization id from t_billgroup_materialization.
============================================================== */
SELECT CAST(COALESCE(MAX(id_materialization), 0) AS INTEGER) ID_MATERIALIZATION
FROM t_billgroup_materialization
 