
			aa.id_ancestor = %%ID_ANCESTOR%% and aa.num_generations >= 0 
      and 
      aa.vt_start <= %%DT_END%% and aa.vt_end >= %%DT_BEGIN%% 
			and
			((au.id_parent_sess IS NULL and au.dt_session >= %%DT_BEGIN%% and au.dt_session <= %%DT_END%%) or
       (au.id_parent_sess IS NOT NULL and auparent.dt_session >= %%DT_BEGIN%% and auparent.dt_session <= %%DT_END%%))
			 