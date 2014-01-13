
      IF OBJECT_ID('tmp_ARAdjustments') IS NOT NULL
        DROP TABLE tmp_ARAdjustments;

      SELECT TOP %%SET_SIZE%%
        '%%ID_PREFIX%%' + CONVERT(varchar, pv.id_sess) as AdjustmentID,
        CASE WHEN au.amount < 0 THEN 'Credit' ELSE 'Debit' END as Type,
        ISNULL(b.tx_name, '%%DEF_BATCH_ID%%') as BatchID,
        pv.c_Description as Description,
        pv.c_EventDate as AdjustmentDate,
        am.ExtAccount as ExtAccountID,
        CASE WHEN au.amount < 0 THEN -au.amount ELSE au.amount END as Amount,
        au.am_currency as Currency
      INTO tmp_ARAdjustments
      FROM t_pv_ARAdjustment pv
        JOIN t_acc_usage au ON pv.id_sess = au.id_sess
        and au.id_usage_interval=pv.id_usage_interval
        INNER JOIN vw_ar_acc_mapper am ON am.id_acc = au.id_acc and am.ExtNamespace = '%%ACC_NAME_SPACE%%'
        LEFT OUTER JOIN t_batch b ON b.tx_batch = au.tx_batch AND tx_namespace = '%%BATCH_NAME_SPACE%%'
      WHERE c_ARBatchID IS NULL
        AND pv.c_Source <> 'AR'
      