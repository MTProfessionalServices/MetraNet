
update t_batch
  set
      	t_batch.n_failed = (select COUNT(*) from t_failed_transaction ft where ft.tx_Batch_Encoded=t_batch.tx_Batch_Encoded and ft.State in ('I','N','C')),
	t_batch.n_dismissed = (select COUNT(*) from t_failed_transaction ft where ft.tx_Batch_Encoded=t_batch.tx_Batch_Encoded and ft.State='P')
  from
    t_batch
        inner join
    t_failed_transaction
        on
    t_batch.tx_batch_encoded = t_failed_transaction.tx_Batch_Encoded
        where
    t_failed_transaction.tx_FailureCompoundID = %%FAILURECOMPOUNDID%%
			