    
  UPDATE t_adjustment_transaction adj
  SET ARDelBatchID = '%%BATCH_ID%%', ARDelAction = tmp.ARDelAction
  WHERE EXISTS (
    SELECT 'X' FROM  tmp_PBAdjustments tmp 
    WHERE tmp.ID = adj.id_adj_trx)
        