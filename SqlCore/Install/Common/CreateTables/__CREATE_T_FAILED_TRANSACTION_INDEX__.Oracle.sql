
          CREATE INDEX tx_FailureCompoundID_idx ON t_failed_transaction(tx_FailureCompoundID);
          CREATE INDEX t_failed_transaction_batch_idx ON t_failed_transaction(tx_batch_encoded);
          CREATE INDEX tx_failureid_idx on T_FAILED_TRANSACTION(TX_FAILUREID);
