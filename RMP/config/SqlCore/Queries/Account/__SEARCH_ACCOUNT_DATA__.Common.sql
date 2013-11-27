
				SELECT 
				a.id_acc accountid, 
 				state.vt_start accountstartdate,
				state.vt_end accountenddate,
				b.nm_login username, 
 				b.nm_space name_space,
 				d.c_currency currency, 
				'' password_ , 
 				uc.day_of_month dayofmonth, 
 				uc.day_of_week dayofweek, 
				uc.first_day_of_month firstdayofmonth, 
				uc.second_day_of_month seconddayofmonth, 
 				uc.start_day startday,
				uc.start_month startmonth, 
 				uc.start_year startyear
			FROM 
 				t_account a
				INNER JOIN t_account_state state on state.id_acc = a.id_acc AND 
 				state.vt_start <= %%%SYSTEMDATE%%% and %%%SYSTEMDATE%%% < state.vt_end
				INNER JOIN t_account_mapper b on b.id_acc = a.id_acc
				INNER JOIN t_av_internal d on d.id_acc = a.id_acc
				LEFT OUTER JOIN t_acc_usage_cycle auc on auc.id_acc = a.id_acc
				LEFT OUTER JOIN t_usage_cycle uc on uc.id_usage_cycle = auc.id_usage_cycle
				LEFT OUTER JOIN t_usage_cycle_type uct on uct.id_cycle_type = 
				uc.id_cycle_type,
				t_namespace ns 
			WHERE 
 				b.id_acc = %%ACCOUNT_ID%% AND
 				%%NAME_SPACE%% AND
 				ns.nm_space = b.nm_space
			