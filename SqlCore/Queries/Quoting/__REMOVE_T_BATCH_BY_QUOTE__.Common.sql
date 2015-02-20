 DELETE from t_batch
 WHERE 
  tx_Batch in (%%BATCHES_IDS%%)