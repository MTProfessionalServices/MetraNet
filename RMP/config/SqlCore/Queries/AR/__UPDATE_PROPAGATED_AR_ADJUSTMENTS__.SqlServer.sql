
        UPDATE t_pv_ARAdjustment
        SET c_ARBatchID = '%%BATCH_ID%%'
        FROM  t_pv_ARAdjustment pv
        JOIN tmp_ARAdjustments tmp ON tmp.AdjustmentID = '%%ID_PREFIX%%' + CONVERT(varchar, pv.id_sess)
        