
/* ===========================================================
Returns the id_usage_interval for the given id_materialization
=========================================================== */
SELECT id_usage_interval UsageIntervalID          
FROM t_billgroup_materialization
WHERE id_materialization = %%ID_MATERIALIZATION%%
   