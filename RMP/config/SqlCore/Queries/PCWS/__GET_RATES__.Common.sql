
              select 
                 id_sched ScheduleID, n_order  RateIndex %%COLUMNS%% 
              from 
                %%TABLE_NAME%% 
             where
                id_sched = %%ID_SCHED%%
             order by n_order asc
		  