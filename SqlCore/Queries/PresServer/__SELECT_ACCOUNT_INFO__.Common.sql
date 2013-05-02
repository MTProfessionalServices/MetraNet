
			select a.id_acc,
			state.vt_start dt_start,
			state.vt_end dt_end,
			av.c_currency tx_currency,
			u.id_usage_cycle id_usage_cycle
			from t_account a
			INNER JOIN t_account_mapper am on 
				%%%UPPER%%%(am.nm_login) = %%%UPPER%%%(N'%%LOGIN_ID%%') and 
				%%%UPPER%%%(am.nm_space) = %%%UPPER%%%(N'%%NAME_SPACE%%') and 
				am.id_acc = a.id_acc
			INNER JOIN t_av_internal av on av.id_acc = a.id_acc
			INNER JOIN t_acc_usage_cycle u on u.id_acc = a.id_acc
			INNER JOIN t_account_state state on state.id_acc = a.id_acc 
			AND vt_start <= %%%SYSTEMDATE%%% and %%%SYSTEMDATE%%% < vt_end and
			vt_start = (SELECT max (vt_start) FROM t_account_state
			WHERE id_acc = a.id_acc)
			