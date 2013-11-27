
			  cast((select count(*) from %%PARAMTABLEDBNAME%% pt where t_rsched.id_sched = pt.id_sched AND pt.tt_start<=%%%SYSTEMDATE%%% AND pt.tt_end>%%%SYSTEMDATE%%%) as varchar(15)) %%%CONCAT%%% ' Rules'
			