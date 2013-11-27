
/* ===========================================================
Delete the interval-account mappings for paying accounts for the given interval.
============================================================== */
DELETE from t_acc_usage_interval 
where exists (
  select 1 
  from vw_paying_accounts pa  
  WHERE pa.intervalId = t_acc_usage_interval.id_usage_interval  
    and pa.accountId = t_acc_usage_interval.id_acc
    and t_acc_usage_interval.id_usage_interval = %%ID_INTERVAL%% 
  )
 