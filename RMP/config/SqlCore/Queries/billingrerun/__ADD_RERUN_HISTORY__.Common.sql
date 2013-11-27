
			  insert into t_rerun_history (id_rerun, dt_action, tx_action,
						id_acc, tx_comment)
					values (%%ID_RERUN%%, %%%SYSTEMDATE%%%, '%%ACTION%%', %%ID_ACC%%,
							N'%%COMMENT%%')
      