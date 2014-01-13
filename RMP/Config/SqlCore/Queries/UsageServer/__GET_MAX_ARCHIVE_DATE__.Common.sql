
			select max(ui.dt_end) 
			from t_acc_usage_interval au inner join t_archive ar on au.id_usage_interval=ar.id_interval
			inner join t_usage_interval ui on ui.id_interval=ar.id_interval
			where ar.status = 'A'
			and tt_end=dbo.mtmaxdate()
			and au.id_acc=%%ID_ACC%%
	