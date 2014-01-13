
	DELETE FROM %%PV_TABLE%% 
  WHERE
  EXISTS
  (
	  SELECT 1
		FROM t_acc_usage
    WHERE
		t_acc_usage.id_sess=%%PV_TABLE%%.id_sess and t_acc_usage.id_usage_interval=%%PV_TABLE%%.id_usage_interval
    AND %%WHERE_CLAUSE%%
  )
  