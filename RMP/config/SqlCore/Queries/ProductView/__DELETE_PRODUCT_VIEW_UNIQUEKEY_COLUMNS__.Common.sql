
			delete from t_unique_cons_columns 
			where id_unique_cons in 
				(select id_unique_cons from t_unique_cons 
				 where id_prod_view = %%ID_PROD_VIEW%%)
		