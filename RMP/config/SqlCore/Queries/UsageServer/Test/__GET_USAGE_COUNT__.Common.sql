
/* ===========================================================
Get accounts from t_acc_usage based on id_view
============================================================== */
SELECT COUNT(id_acc) UsageCount 
FROM t_acc_usage 
WHERE id_usage_interval = %%ID_INTERVAL%%
 