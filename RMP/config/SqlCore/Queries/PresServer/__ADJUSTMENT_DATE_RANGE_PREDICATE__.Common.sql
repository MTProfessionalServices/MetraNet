
			((au.id_parent_sess IS NULL and au.dt_session >= %%DT_BEGIN%% and au.dt_session <= %%DT_END%%) or
       (au.id_parent_sess IS NOT NULL and auparent.dt_session >= %%DT_BEGIN%% and auparent.dt_session <= %%DT_END%%))
			 