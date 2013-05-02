
					select distinct ui.id_interval IntervalID, ui.dt_start StartDate, 
					ui.dt_end EndDate, ui.tx_interval_status Status,ti.invoice_string InvoiceNumber,
					case status
					when 'A' then 'A'
					when 'D' then 'D'
					else 'N'
					end as archive
					from t_usage_interval ui
					inner join t_acc_usage_interval aui on ui.id_interval = aui.id_usage_interval and ui.dt_start < to_date('%%DATE%%','mm-dd-yyyy hh24:mi:ss')
					left outer join t_invoice ti on ti.id_acc = aui.id_acc and ti.id_interval = aui.id_usage_interval 
					left outer join t_acc_bucket_map ar on aui.id_usage_interval=ar.id_usage_interval 
					and aui.id_acc = ar.id_acc and tt_end = dbo.mtmaxdate()
					where aui.id_acc = %%ACCOUNT_ID%% 
					and (aui.dt_effective is null or (aui.dt_effective is not null and to_date('%%DATE%%','mm-dd-yyyy hh24:mi:ss') > aui.dt_effective)) 
					and aui.id_usage_interval not in (select id_usage_interval from t_acc_bucket_map where status='A' and tt_end=dbo.mtmaxdate()
					and id_acc = %%ACCOUNT_ID%%)
			order by ui.dt_end DESC
		