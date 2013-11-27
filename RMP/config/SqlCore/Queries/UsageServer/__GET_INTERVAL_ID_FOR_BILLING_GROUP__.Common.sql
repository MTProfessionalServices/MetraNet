
/* ===========================================================
Returns the interval id for the given billing group id.
=========================================================== */
SELECT id_usage_interval
FROM t_billgroup
WHERE id_billgroup = %%ID_BILLGROUP%% 
   