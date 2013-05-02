
    INSERT INTO 
		%%SVC_TABLE%% (id_source_sess, id_parent_source_sess, id_external, %%SVC_COLUMNS%%, c__IntervalID, c__TransactionCookie, c__Resubmit, c__CollectionID)
    SELECT rr.id_source_sess, rr.id_parent_source_sess, NULL, %%PV_COLUMNS%%, au.id_usage_interval, NULL, '1', au.tx_batch
    FROM %%PV_TABLE%% pv
    INNER JOIN t_acc_usage au ON au.id_sess=pv.id_sess
		INNER JOIN %%RERUN_TABLE%% rr ON rr.id_sess=au.id_sess
		WHERE
    rr.tx_state = 'A'
		AND 
		rr.id_svc = %%ID_SVC%%
		AND
		rr.id_view = %%ID_VIEW%%
		