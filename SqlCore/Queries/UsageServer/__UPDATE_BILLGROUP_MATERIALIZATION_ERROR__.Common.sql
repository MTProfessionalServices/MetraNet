
/* ===========================================================
Sets the tx_status to 'Failed' or 'Aborted' with the failure reason
for the given id_materialization in t_billgroup_materialization
=========================================================== */
UPDATE t_billgroup_materialization
SET tx_status = %%STATUS%%, tx_failure_reason = %%FAILURE_REASON%%
WHERE id_materialization = %%ID_MATERIALIZATION%%
   