
        UPDATE t_pv_Payment
        SET c_ARBatchID = '%%BATCH_ID%%'
        FROM  t_pv_Payment pv
        JOIN tmp_ARPayments pm ON pm.PaymentID = '%%ID_PREFIX%%' + CONVERT(varchar, pv.id_sess)
        