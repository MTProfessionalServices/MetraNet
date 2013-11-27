
/* ===========================================================
   Returns rows from t_billgroup_materialization which have a tx_status of 'InProgress'
   for the given intervalID
   =========================================================== */
SELECT * 
FROM t_billgroup_materialization bm
WHERE bm.tx_status = 'InProgress' AND
      bm.id_usage_interval = %%ID_INTERVAL%%
	