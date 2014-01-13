
/* ===========================================================
Return the id_materialization for the given interval, if
it has been fully materialized. 
=========================================================== */
SELECT id_materialization 
FROM t_billgroup_materialization bm
WHERE bm.tx_status = 'Succeeded' AND
            bm.tx_type = 'Full' AND
            bm.id_usage_interval = %%ID_INTERVAL%%
   