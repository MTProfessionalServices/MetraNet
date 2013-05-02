
          CREATE INDEX tx_FailureCompoundID_idx ON t_failed_transaction(tx_FailureCompoundID);
          CREATE INDEX t_failed_transaction_batch_idx ON t_failed_transaction(tx_batch_encoded);

