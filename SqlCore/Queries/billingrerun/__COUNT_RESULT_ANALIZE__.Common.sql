
 select COUNT(*) AS analyze_count from %%TABLE_NAME%% where tx_state <> 'C' AND tx_state <> 'S'
  