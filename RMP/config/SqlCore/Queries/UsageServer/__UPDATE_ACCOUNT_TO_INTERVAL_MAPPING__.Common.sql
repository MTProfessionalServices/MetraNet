

					insert into t_acc_usage_interval (id_acc, 
					                                  id_usage_interval,
					                                  tx_status) 
				  select auc.id_acc, %%INTERVAL_ID%%, ui.tx_interval_status 
				  from t_acc_usage_cycle auc
				  inner join t_usage_interval ui
				    on ui.id_usage_cycle = auc.id_usage_cycle
				  where auc.id_usage_cycle=%%CYCLE_ID%% and
					      id_acc not in (select id_acc from t_acc_usage_interval 
					                     where id_usage_interval = %%INTERVAL_ID%%) and
					      ui.id_interval = %%INTERVAL_ID%% AND
					      ui.tx_interval_status != 'B'
        