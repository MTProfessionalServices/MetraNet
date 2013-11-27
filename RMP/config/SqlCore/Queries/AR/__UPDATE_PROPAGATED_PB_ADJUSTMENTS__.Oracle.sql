
    UPDATE t_adjustment_transaction adj
    SET ARBatchID = '%%BATCH_ID%%'
    WHERE EXISTS (
      SELECT 'X' FROM  tmp_PBAdjustments tmp 
      WHERE tmp.AdjustmentID = '%%ID_PREFIX%%' + cast(adj.id_adj_trx  as varchar(100)))
         