
           select * 
           /* __GET_ALL_PARAM_TABLE_VALUES__ */
           from %%TABLE_NAME%% 
           WHERE %%%SYSTEMDATE%%% >= tt_start AND %%%SYSTEMDATE%%% <= tt_end
           order by id_sched, n_order
           