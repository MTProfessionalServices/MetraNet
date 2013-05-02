
				SELECT id_failed_transaction
				FROM   t_failed_transaction
				WHERE  tx_FailureCompoundID_Encoded = '%%FAIL_COMP_ID_ENC%%'
				       AND STATE <> 'R'
            