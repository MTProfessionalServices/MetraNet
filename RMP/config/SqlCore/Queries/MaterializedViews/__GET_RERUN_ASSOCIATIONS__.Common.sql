
			select pv.nm_table_name from t_prod_view pv inner join %%TABLE_NAME%% rr on rr.id_view = pv.id_view where rr.tx_state = 'A' group by pv.nm_table_name
		