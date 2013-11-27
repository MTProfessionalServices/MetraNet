	   
 	begin
		    declare p_mtmaxdate timestamp;
		    begin
	        p_mtmaxdate := dbo.MTMaxDate(); 	
	        
	        update t_session_state ss
		        set ss.dt_end = p_mtmaxdate
		        where exists(select ss.id_sess from 
		        %%RERUN_TABLE_NAME%%  rr
		      where rr.id_source_sess = ss.id_sess
		      and ss.dt_end = p_mtmaxdate
		      and rr.tx_state = 'B');

	      INSERT INTO t_session_state (id_sess, dt_start, dt_end, tx_state) 
		        SELECT rr.id_source_sess, %%METRADATE%%,  p_mtmaxdate , 'R'
		        from %%RERUN_TABLE_NAME%% rr
		        where rr.tx_state = 'B';
		    end;
	end;

	  