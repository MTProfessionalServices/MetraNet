
			SELECT 
			/* __GET_OWNERSHIP_BATCH_ERRORS__ */
			own.id_owner, 
			own.id_owned, 
			'Owner Account ID <' %%%CONCAT%%% CAST(own.id_owner AS VARCHAR2(20)) %%%CONCAT%%% '>' ownername,
      'Owned Account ID <' %%%CONCAT%%% CAST(own.id_owned AS VARCHAR2(20)) %%%CONCAT%%% '>'  ownedname,
			own.status FROM
      %%%TEMP_TABLE_PREFIX%%%tmp_acc_ownership_batch own
      WHERE
			own.status <> 0 
		  