
			aa.id_ancestor = %%ID_ANCESTOR%% and aa.num_generations >= 0 
      and 
      aa.vt_start <= %%DT_END%% and aa.vt_end >= %%DT_BEGIN%% 
      and 
      (au.dt_session >= aa.vt_start and au.dt_session <= aa.vt_end)
			 