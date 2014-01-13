
BEGIN 
  DELETE FROM %%SECOND_PASS_PV_TABLE_NAME%%
  WHERE EXISTS 
  (
    SELECT 1 
    FROM t_acc_usage
    WHERE 
      id_usage_interval %%USAGE_INTERVAL_FILTER%% AND
      id_pi_template = %%ID_PI_TEMPLATE%% AND
      id_view = %%SECOND_PASS_VIEW_ID%% AND
      id_sess = %%SECOND_PASS_PV_TABLE_NAME%%.id_sess AND
      id_usage_interval = %%SECOND_PASS_PV_TABLE_NAME%%.id_usage_interval
      %%BILLING_GROUP_FILTER%% 
  );

  DELETE FROM t_acc_usage
  WHERE
    id_usage_interval %%USAGE_INTERVAL_FILTER%% AND
    id_pi_template = %%ID_PI_TEMPLATE%% AND
    id_view = %%SECOND_PASS_VIEW_ID%%
    %%BILLING_GROUP_FILTER%% ;

END;
           