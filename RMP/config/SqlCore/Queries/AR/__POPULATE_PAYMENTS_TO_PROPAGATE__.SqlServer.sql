
      IF OBJECT_ID('tmp_ARPayments') IS NOT NULL
        DROP TABLE tmp_ARPayments;

      SELECT TOP %%SET_SIZE%%
        '%%ID_PREFIX%%' + CONVERT(varchar, pv.id_sess) as PaymentID,
        ISNULL(b.tx_name, '%%DEF_BATCH_ID%%') as BatchID,
        pv.c_Description as Description,
        pv.c_EventDate as PaymentDate,
        am.ExtAccount as ExtAccountID,
        -au.amount as Amount,
        au.am_currency as Currency,
        substring(em.nm_enum_data, 48, 256) as PaymentMethod,
        substring(ed.nm_enum_data, 30, 256) as CCType,
        pv.c_CheckOrCardNumber as CheckOrCardNumber
      INTO tmp_ARPayments
      FROM t_pv_Payment pv
        JOIN t_acc_usage au ON pv.id_sess = au.id_sess
        and au.id_usage_interval=pv.id_usage_interval
        INNER JOIN vw_ar_acc_mapper am ON am.id_acc = au.id_acc and am.ExtNamespace = '%%ACC_NAME_SPACE%%'
        LEFT OUTER JOIN t_enum_data em ON em.id_enum_data = pv.c_PaymentMethod
        LEFT OUTER JOIN t_enum_data ed ON ed.id_enum_data = pv.c_CCType
        LEFT OUTER JOIN t_batch b ON b.tx_batch = au.tx_batch AND tx_namespace = '%%BATCH_NAME_SPACE%%'
      WHERE c_ARBatchID IS NULL
        AND pv.c_Source <> 'AR'
      