	   
		    declare @mtmaxdate datetime
	      set @mtmaxdate = dbo.MTMaxDate() 	
	      update t_session_state
		        set dt_end =  %%METRADATE%%
		        from %%RERUN_TABLE_NAME%%  rr
		      inner join t_session_state ss WITH (READCOMMITTED)
		      on rr.id_source_sess = ss.id_sess
		      where ss.dt_end = @mtmaxdate
		      and rr.tx_state = 'B'

	      INSERT INTO t_session_state (id_sess, dt_start, dt_end, tx_state) 
		        SELECT rr.id_source_sess, %%METRADATE%%,  @mtmaxdate , 'R'
		        from %%RERUN_TABLE_NAME%% rr
		        where rr.tx_state = 'B'

	  