
			SELECT ub.id_acc, am.displayname as accountname, 'Batch Unsubscribe failed' as description, ub.status FROM
      #tmp_unsubscribe_batch ub
      INNER JOIN VW_MPS_ACC_MAPPER am on am.id_acc=ub.id_acc
      WHERE
			ub.status <> 0 
		