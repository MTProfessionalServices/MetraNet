
      SELECT id_failed_transaction id_case 
      FROM t_failed_transaction 
      WHERE tx_FailureID_encoded = '%%SESSION_UID%%' AND
            state != 'R'
		