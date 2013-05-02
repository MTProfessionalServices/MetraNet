
    
    
    update %%TABLE_NAME%% rr1
    SET rr1.id_source_sess = (select CAST(rr1.id + %%ID_BASE%% AS BINARY(16))
                              FROM t_prod_view pv
                              where rr1.id_view = pv.id_view
                              and pv.b_can_resubmit_from = 'Y' 
                              AND rr1.tx_state = 'A') 
    and exists
    (select 1 from t_prod_view pv
     where rr1.id_view = pv.id_view
                              and pv.b_can_resubmit_from = 'Y' 
                              AND rr1.tx_state = 'A')
		