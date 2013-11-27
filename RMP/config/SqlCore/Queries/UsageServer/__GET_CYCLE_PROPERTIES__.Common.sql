

           select * from t_usage_cycle uc, t_usage_cycle_type uct
           where uc.id_usage_cycle = %%CYCLE_ID%% and uc.id_cycle_type
           = uct.id_cycle_type

        