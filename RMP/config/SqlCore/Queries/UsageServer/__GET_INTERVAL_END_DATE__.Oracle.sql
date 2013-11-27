
					select TO_CHAR(ui.dt_end, 'MM/DD/YYYY') EndDate from t_acc_usage_interval aui,  
					t_usage_interval ui where aui.id_usage_interval = ui.id_interval and  
					aui.id_acc = %%ACCOUNT_ID%% and ui.dt_start < '%%UTCDATE%%' and ui.dt_end > '%%UTCDATE%%'
				