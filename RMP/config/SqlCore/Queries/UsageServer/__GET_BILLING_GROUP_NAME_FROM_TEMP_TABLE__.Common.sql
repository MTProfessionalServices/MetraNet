
/* ===========================================================
Returns the billing group name from the temporary t_billgroup_tmp
table given the materialization id.
=========================================================== */
SELECT tx_name
FROM t_billgroup_tmp
WHERE id_materialization = %%ID_MATERIALIZATION%% 
   