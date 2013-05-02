
			  /* first 'Orphanize' Pending or approved Transactions */
        update t_adjustment_transaction SET id_sess = NULL, id_parent_sess = NULL, c_Status = 'O'
        WHERE id_sess IN %%ID_SESS_LIST%%
        /* below predicate is redundant, because */
        /* session list at this point will ONLY have 'P' and 'A' */
        /* transactions */
        AND c_status IN ('A', 'P')
			