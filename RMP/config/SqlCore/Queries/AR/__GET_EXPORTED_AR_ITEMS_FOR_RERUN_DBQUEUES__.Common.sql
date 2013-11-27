    
        SELECT rr.id_sess AS ID, NULL AS Type
        FROM %%RERUN_TABLE_NAME%% rr
        INNER JOIN t_pv_Payment pv ON pv.id_sess = rr.id_sess
	and pv.id_usage_interval = rr.id_interval
        WHERE rr.tx_state = 'A'
        AND pv.c_ARBatchID IS NOT NULL
        UNION
        SELECT rr.id_sess AS ID,
        CASE WHEN au.amount < 0 THEN 'Credit' ELSE 'Debit' END AS Type
        FROM %%RERUN_TABLE_NAME%% rr
        INNER JOIN t_pv_ARAdjustment pv ON pv.id_sess = rr.id_sess
	and pv.id_usage_interval = rr.id_interval
        INNER JOIN t_acc_usage au ON au.id_sess = rr.id_sess
	and au.id_usage_interval = rr.id_interval
        WHERE rr.tx_state = 'A'
        AND pv.c_ARBatchID IS NOT NULL
        