 DELETE from t_failed_transaction
 WHERE 
  tx_Batch in (%%BATCHES_IDS%%)