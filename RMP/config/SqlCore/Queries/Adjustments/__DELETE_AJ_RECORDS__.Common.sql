
			  delete from t_adjustment_transaction
			  WHERE id_adj_trx IN %%ID_AJ_LIST%%
			   /* below predicate is redundant, because */
        /* session list at this point will ONLY have 'D' */
        /* transactions */
			  AND c_status IN ('D')
			