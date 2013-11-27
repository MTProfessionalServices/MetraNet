
        select	dt_start "Date" 
	      from	(select dt_start from  t_pc_interval where id_cycle=2 order by dt_start desc) temp where rownum = 1
		    