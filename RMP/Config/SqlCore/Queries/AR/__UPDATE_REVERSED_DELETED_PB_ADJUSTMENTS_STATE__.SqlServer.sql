    
          UPDATE t_adjustment_transaction
          SET ARDelBatchID = NULL, ARDelAction = NULL
          FROM  t_adjustment_transaction adj
          JOIN tmp_ARReverse tmp ON tmp.ID = adj.id_adj_trx
        