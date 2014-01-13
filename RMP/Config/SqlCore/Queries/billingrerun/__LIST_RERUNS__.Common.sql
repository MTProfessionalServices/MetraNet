
select t_rerun.id_rerun, dt_action, tx_comment from t_rerun
	inner join t_rerun_history on t_rerun.id_rerun = t_rerun_history.id_rerun
	order by t_rerun.id_rerun
			