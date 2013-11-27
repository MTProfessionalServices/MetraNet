
				select ui.id_interval IntervalID, ui.dt_start StartDate, 
			  ui.dt_end EndDate, ui.tx_interval_status Status,
			  ti.invoice_string InvoiceNumber from t_acc_usage_interval aui
				inner join  t_usage_interval ui on ui.id_interval = aui.id_usage_interval
				left outer join t_invoice ti on aui.id_acc = ti.id_acc
				and aui.id_usage_interval = ti.id_interval  
				where aui.id_acc = %%ACCOUNT_ID%% 
			  order by ui.dt_start DESC
			