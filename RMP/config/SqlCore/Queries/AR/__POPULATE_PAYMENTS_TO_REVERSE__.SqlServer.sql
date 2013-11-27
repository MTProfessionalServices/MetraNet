
      IF OBJECT_ID('tmp_ARReverse') IS NOT NULL
        DROP TABLE tmp_ARReverse;

      SELECT TOP %%SET_SIZE%%
        pv.id_sess as ID,
        ISNULL(b.tx_name, '%%AR_BATCH_ID%%') as BatchID,
        am.ExtNamespace as Namespace
      INTO tmp_ARReverse
      FROM t_pv_payment pv
        JOIN t_acc_usage au ON pv.id_sess = au.id_sess and au.id_usage_interval=pv.id_usage_interval
        LEFT OUTER JOIN t_batch b ON b.tx_batch = au.tx_batch AND tx_namespace = '%%BATCH_NAME_SPACE%%'
        INNER JOIN vw_ar_acc_mapper am ON am.id_acc = au.id_acc
      WHERE c_ARBatchID = '%%AR_BATCH_ID%%'
      