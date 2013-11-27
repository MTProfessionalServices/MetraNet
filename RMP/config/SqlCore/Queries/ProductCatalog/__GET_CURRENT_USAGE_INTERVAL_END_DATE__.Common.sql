
			select dt_end from t_pc_interval 
			where id_cycle = %%ID_USAGE_CYCLE%% 
			  and dt_start <= %%DT_EFF%% and %%DT_EFF%% <= dt_end
    