
      select uc.id_usage_cycle CycleID from t_usage_cycle uc, t_acc_usage_cycle auc 
      where auc.id_usage_cycle = uc.id_usage_cycle and auc.id_acc = %%ACCOUNT_ID%% 
      and id_cycle_type = %%CYCLE_TYPE%% %%EXT%%
        