
	UPDATE %%TABLE_NAME%% rr2
    SET rr2.id_parent_source_sess = (select CAST(rr1.id + %%ID_BASE%% AS BINARY(16))
		FROM %%TABLE_NAME%% rr1
		INNER JOIN t_prod_view pv ON rr1.id_view=pv.id_view
        where rr1.id_source_sess=rr2.id_parent_source_sess
		and
        pv.b_can_resubmit_from = 'Y' AND rr1.tx_state = 'A' AND rr2.id_parent_source_sess IS NOT NULL)
and exists
(select 1 from  %%TABLE_NAME%% rr1
		INNER JOIN t_prod_view pv ON rr1.id_view=pv.id_view
        where rr1.id_source_sess=rr2.id_parent_source_sess
		and
        pv.b_can_resubmit_from = 'Y' AND rr1.tx_state = 'A' AND rr2.id_parent_source_sess IS NOT NULL);
       