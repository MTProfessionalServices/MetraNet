
			  LEFT JOIN %%PARAMTABLEDBNAME%% pt on t_rsched.id_sched = pt.id_sched AND pt.tt_start<=%%%SYSTEMDATE%%% AND pt.tt_end>%%%SYSTEMDATE%%%
			