	   
 	begin
		declare p_mtmaxdate timestamp;
		begin
			p_mtmaxdate := dbo.MTMaxDate(); 	
	        
			UPDATE t_session_state ss
			SET ss.dt_end = %%METRADATE%%
			WHERE (ss.id_sess, ss.dt_end) in 
			(SELECT rr.id_source_sess, p_mtmaxdate 
			FROM %%RERUN_TABLE_NAME%% rr
			WHERE rr.tx_state = 'B');	        

			INSERT INTO t_session_state (id_sess, dt_start, dt_end, tx_state) 
			SELECT rr.id_source_sess, %%METRADATE%%,  p_mtmaxdate , 'R'
			FROM %%RERUN_TABLE_NAME%% rr
			WHERE rr.tx_state = 'B';
		end;
 	end;

