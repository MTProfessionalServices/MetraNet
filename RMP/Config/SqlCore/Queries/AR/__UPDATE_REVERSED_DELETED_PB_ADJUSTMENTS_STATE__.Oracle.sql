    
  UPDATE t_adjustment_transaction adj
  SET ARDelBatchID = NULL, ARDelAction = NULL
  WHERE EXISTS (
    SELECT 'X' FROM  tmp_ARReverse tmp 
    WHERE tmp.ID = adj.id_adj_trx)
        