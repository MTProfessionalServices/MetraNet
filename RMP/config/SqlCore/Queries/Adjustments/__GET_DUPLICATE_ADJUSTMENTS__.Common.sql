
	/* Return those id_sess' in %%ID_SESS_LIST%% which have more than one 'Pending' or 'Approved'
	 entry for the same adjustment type. */
	SELECT id_sess, n_adjustmenttype
  FROM %%TABLE_NAME%%
  WHERE id_sess IN (%%ID_SESS_LIST%%)  AND
        c_status IN ('P', 'A') /* CR 14255. Only those adjustments which are 'Pending' or 'Approved' */
  GROUP BY id_sess, n_adjustmenttype
  HAVING COUNT(id_sess) > 1
