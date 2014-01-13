
				select * from t_adjustment_transaction ajt inner join t_adjustment aj ON ajt.id_aj_template  = aj.id_prop
				where id_parent_sess = %%PARENTSESSIONID%% AND aj.id_pi_template = %%PITEMPLATEID%% AND %%%UPPER%%%(ajt.c_status) IN ('A', 'P')
			