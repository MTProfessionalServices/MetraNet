
        /*__GET_ANCESTOR_COUNT__*/
        select count(*) as c_cnt_descendents from t_account_ancestor where id_ancestor = %%ID_ACC%% and num_generations != 0 
        and sysdate between vt_start and vt_end
        