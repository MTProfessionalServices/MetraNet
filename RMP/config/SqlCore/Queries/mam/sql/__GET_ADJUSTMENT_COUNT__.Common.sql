
				select * from t_adjustment_transaction ajt where
				id_parent_sess = %%PARENTSESSIONID%% AND %%%UPPER%%%(ajt.c_status) IN ('A', 'P') and n_adjustmenttype=%%PREBILL_FLAG%%
			