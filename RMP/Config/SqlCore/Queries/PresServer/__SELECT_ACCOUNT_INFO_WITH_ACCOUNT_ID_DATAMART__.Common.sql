
				/* Raju: take it out later
			    select a.id_acc, a.dt_start dt_start, a.dt_end dt_end, i.c_currency tx_currency, 
				u.id_usage_cycle id_usage_cycle
			    from t_account a, t_av_internal i, t_acc_usage_cycle u 
				where a.id_acc = %%ACCOUNT_ID%% and 
				a.id_acc = i.id_acc and a.id_acc = u.id_acc
				*/
			    select 
					   a.id_acc, 
					   astate.vt_start dt_start, 
					   astate.vt_end dt_end, 
					   i.c_currency tx_currency,
					   u.id_usage_cycle id_usage_cycle
			    from 
					 t_account a, 
					 t_account_state astate, 
					 t_av_internal i,
					 t_acc_usage_cycle u
				where 
					  a.id_acc = %%ACCOUNT_ID%% and 
					  a.id_acc = i.id_acc and
					  a.id_acc = u.id_acc and 
					  a.id_acc = astate.id_acc and
					  astate.vt_start = (select max (vt_start) from t_account_state where id_acc = %%ACCOUNT_ID%%)
        