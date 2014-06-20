
				UPDATE t_batch b
				SET    b.n_failed = (
				           SELECT COUNT(*)
				           FROM   t_failed_transaction ft
				           WHERE  ft.tx_Batch_Encoded = b.tx_Batch_Encoded
				                  AND ft.State in ('I','N','C')
				       ),
				       b.n_dismissed = (
				           SELECT COUNT(*)
				           FROM   t_failed_transaction ft
				           WHERE  ft.tx_Batch_Encoded = b.tx_Batch_Encoded
				                  AND ft.State = 'P'
				       )
				WHERE  EXISTS (
				           SELECT 1
				           FROM   t_failed_transaction f
				           WHERE  b.tx_batch_encoded = f.tx_batch_encoded
				                  AND f.tx_FailureCompoundID = %%FAILURECOMPOUNDID%%
				       )
			