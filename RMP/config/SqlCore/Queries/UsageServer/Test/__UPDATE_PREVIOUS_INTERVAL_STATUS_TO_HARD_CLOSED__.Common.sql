
/* ===========================================================
Update the status of intervals before the given date to hard closed.
============================================================== */
UPDATE t_usage_interval
SET tx_interval_status = 'H'
WHERE dt_start < %%DT_START%%
 