    
      IF OBJECT_ID('tmp_ARReverse') IS NOT NULL
        DROP TABLE tmp_ARReverse;

      SELECT
        pv.id_sess as ID,
        CASE WHEN au.amount < 0 THEN 'Credit' ELSE 'Debit' END as Type,
        ISNULL(b.tx_name, pv.c_ARBatchID) as BatchID,
        am.ExtNamespace as Namespace
        INTO tmp_ARReverse
        FROM t_pv_ARAdjustment pv
        JOIN t_acc_usage au ON pv.id_sess = au.id_sess
        LEFT OUTER JOIN t_batch b ON b.tx_batch = au.tx_batch AND tx_namespace = '%%BATCH_NAME_SPACE%%'
        INNER JOIN %%RERUN_TABLE_NAME%% rr ON pv.id_sess = rr.id_sess
        INNER JOIN vw_ar_acc_mapper am ON am.id_acc = au.id_acc
        WHERE rr.tx_state = 'A' AND pv.c_ARBatchID IS NOT NULL
      