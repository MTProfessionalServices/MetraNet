select id_cycle_type as AccountCycleType from t_acc_usage_cycle auc
join t_usage_cycle uc on auc.id_usage_cycle = uc.id_usage_cycle
where auc.id_acc=%%ACCOUNT_ID%%