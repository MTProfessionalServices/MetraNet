
      IF OBJECT_ID('tmp_ARReverse') IS NOT NULL
        DROP TABLE tmp_ARReverse;

      SELECT TOP %%SET_SIZE%%
        adj.id_adj_trx as ID,
        CASE WHEN adj.AdjustmentAmount < 0 THEN 'Credit' ELSE 'Debit' END as Type,
        '%%AR_BATCH_ID%%' as BatchID,
        am.ExtNamespace as Namespace
      INTO tmp_ARReverse
      FROM t_adjustment_transaction adj
        INNER JOIN vw_ar_acc_mapper am ON am.id_acc = adj.id_acc_payer
      WHERE ARBatchID = '%%AR_BATCH_ID%%'
      