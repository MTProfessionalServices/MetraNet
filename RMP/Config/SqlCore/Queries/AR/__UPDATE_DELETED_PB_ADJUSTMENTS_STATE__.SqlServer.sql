    
          UPDATE t_adjustment_transaction
          SET ARDelBatchID = '%%BATCH_ID%%', ARDelAction = tmp.ARDelAction
          FROM  t_adjustment_transaction adj
          JOIN tmp_PBAdjustments tmp ON tmp.ID = adj.id_adj_trx
        