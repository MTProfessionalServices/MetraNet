
/* ===========================================================
============================================================== */
SELECT *  
FROM t_acc_usage_interval
WHERE id_acc = %%ID_ACC%% AND
      id_usage_interval = %%ID_INTERVAL%%
 