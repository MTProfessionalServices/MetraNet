
begin
  /* ===========================================================
  Update the status of all the paying accounts in the interval to 'H'.
  ============================================================== */
  UPDATE t_acc_usage_interval aui
  SET tx_status = 'H'
  where exists (
    select 1
    FROM vw_paying_accounts pa
    WHERE aui.id_usage_interval = %%ID_INTERVAL%%
      and  pa.IntervalID = aui.id_usage_interval 
      AND pa.AccountID = aui.id_acc);

  UPDATE t_usage_interval 
  SET tx_interval_status = 'H'
  WHERE id_interval = %%ID_INTERVAL%%;
end; 
