
        SELECT seq_no, instruction_no, dt_start, dt_end, description 
        FROM t_mf_tracking_instructions 
        WHERE id_tracking='%%TRACKING_ID%%'
        ORDER BY seq_no
		 