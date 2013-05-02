
			((au.id_parent_sess is null and au.dt_session >= %%DT_BEGIN%% and au.dt_session <= %%DT_END%%) or
       (au.id_parent_sess is not null and auparent.dt_session >= %%DT_BEGIN%% and auparent.dt_session <= %%DT_END%%))
			 