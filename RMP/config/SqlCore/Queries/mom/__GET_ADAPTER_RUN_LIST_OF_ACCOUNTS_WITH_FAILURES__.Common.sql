       
        SELECT distinct(ft.id_PossiblePayerID) AccountID,
          ft.id_PossiblePayeeID PayeeAccountID,
          ft.tx_Batch_Encoded,
          accMap.displayname DisplayName, 
          accMap.nm_login UserName,
          accMap.nm_space Namespace,
          accMapPayee.displayname PayeeDisplayName, 
          accMapPayee.nm_login PayeeUserName,
          accMapPayee.nm_space PayeeNamespace
			  FROM t_failed_transaction ft 
			  LEFT JOIN vw_mps_or_system_acc_mapper accMap ON accMap.id_acc = ft.id_PossiblePayerID
        LEFT JOIN vw_mps_or_system_acc_mapper accMapPayee ON accMapPayee.id_acc = ft.id_PossiblePayeeID
			  INNER JOIN t_recevent_run_batch rrb on ft.tx_Batch_Encoded = rrb.tx_batch_encoded AND rrb.id_run=%%ID_RUN%%
			  WHERE ft.id_PossiblePayerID != -1
			  ORDER BY accMap.displayname
 	    