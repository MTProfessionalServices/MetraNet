
			aa.id_ancestor = %%ID_ANCESTOR%% and aa.num_generations >= 0 
      and 
      aa.vt_start <= %%DT_END%% and aa.vt_end >= %%DT_BEGIN%% 
			and
			((au.id_parent_sess is null and au.dt_session >= %%DT_BEGIN%% and au.dt_session <= %%DT_END%%) or
       (au.id_parent_sess is not null and auparent.dt_session >= %%DT_BEGIN%% and auparent.dt_session <= %%DT_END%%))
			 