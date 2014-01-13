
    UPDATE rr1
    SET rr1.id_source_sess = CAST(rr1.id + %%ID_BASE%% AS BINARY(16))
    FROM %%TABLE_NAME%% rr1
		INNER JOIN t_prod_view pv ON rr1.id_view=pv.id_view
		WHERE
    pv.b_can_resubmit_from = 'Y' AND rr1.tx_state = 'A' 
		