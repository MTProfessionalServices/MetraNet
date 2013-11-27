
	update %%SVC_TABLE_NAME%% svc
          set svc.c__IntervalId = (select rr.id_interval
										from t_usage_interval ui
										inner join %%RERUN_TABLE_NAME%% rr 
										on ui.id_interval = rr.id_interval
										inner join t_acc_usage_interval aui
										on aui.id_usage_interval = rr.id_interval
										where aui.id_acc = rr.id_payer
										and rr.id_interval is not null
										and aui.tx_status = 'C' 
										and rr.id_source_sess = svc.id_source_sess)
		where exists (select 1
										from t_usage_interval ui
										inner join %%RERUN_TABLE_NAME%% rr 
										on ui.id_interval = rr.id_interval
										inner join t_acc_usage_interval aui
										on aui.id_usage_interval = rr.id_interval
										where aui.id_acc = rr.id_payer
										and rr.id_interval is not null
										and aui.tx_status = 'C' 
										and rr.id_source_sess = svc.id_source_sess)						

           
    