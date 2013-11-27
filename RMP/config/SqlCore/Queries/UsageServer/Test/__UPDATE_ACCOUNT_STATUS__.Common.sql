
/* ===========================================================
Update the status of the given accounts/interval to 'C' 
============================================================== */
UPDATE t_acc_usage_interval
  SET tx_status = 'C'
WHERE id_usage_interval = %%ID_INTERVAL%% AND
      id_acc IN (%%ACCOUNT_IDS%%)
