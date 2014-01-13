
/* ===========================================================
Update the status of the given account/interval to 'O' 
============================================================== */
UPDATE t_acc_usage_interval
  SET tx_status = 'O'
WHERE id_usage_interval = %%ID_INTERVAL%% AND
      id_acc = %%ID_ACC%%
