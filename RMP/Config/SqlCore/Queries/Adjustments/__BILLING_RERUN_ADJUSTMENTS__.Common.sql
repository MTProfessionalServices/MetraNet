
			  SELECT * FROM t_adjustment_transaction
			  INNER JOIN t_rerun_sessions rs ON rs.id_sess AND rs.id_rerun = %%ID_RERUN%%
			