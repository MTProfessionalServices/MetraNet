
      delete from t_acc_usage_interval where id_acc = %%ACCOUNT_ID%% and
      id_usage_interval in 
      (select ui.id_interval from t_usage_interval ui, t_acc_usage_interval aui 
      where aui.id_usage_interval = ui.id_interval and aui.id_acc = %%ACCOUNT_ID%% and 
      ui.dt_start > '%%END_DATE%%')
    