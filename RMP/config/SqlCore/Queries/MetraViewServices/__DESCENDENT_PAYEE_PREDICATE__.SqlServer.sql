
			aa.id_ancestor = @idAncestor%%LEVEL%% and aa.num_generations >= 0 
      and 
      aa.vt_start <= @dtAccEnd%%LEVEL%% and aa.vt_end >= @dtAccBegin%%LEVEL%% 
      and 
      (au.dt_session >= aa.vt_start and au.dt_session <= aa.vt_end)
			 