
          /* if we need to support display names later %%ID_LANG%% */
          SELECT 
            id_prop, id_pv_prop, nm_op, nm_value 
          FROM 
            t_counter_param_predicate cpp
          WHERE 
            cpp.id_counter_param = %%ID_PROP%%
       