
       UPDATE t_adjustment_transaction
        SET ARBatchID = '%%BATCH_ID%%'
        FROM  t_adjustment_transaction adj
        JOIN tmp_PBAdjustments tmp ON tmp.AdjustmentID = '%%ID_PREFIX%%' + CONVERT(varchar, adj.id_adj_trx)
         