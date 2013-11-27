
			select COUNT(*) from t_adjustment_transaction adj inner join %%TABLE_NAME%% rr on rr.id_sess = adj.id_sess
		