
/* ===========================================================
Update the status of all the paying accounts in the interval to 'H'.
============================================================== */
UPDATE t_usage_interval 
SET tx_interval_status = 'H'
WHERE id_interval = %%ID_INTERVAL%%
 