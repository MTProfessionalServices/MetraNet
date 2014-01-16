
				create or replace procedure SequencedUpsertAccOwnership
	    	(p_id_owner int,
		    p_id_owned int,
		    p_id_relation_type int,
		    p_percent int,
		    p_vt_start date,
		    p_vt_end date,
		    p_tt_current TIMESTAMP,
		    p_tt_max TIMESTAMP,
		    p_status OUT int)
        as
        begin
          SequencedDeleteAccOwnership (p_id_owner, p_id_owned, p_vt_start, p_vt_end, p_tt_current, p_tt_max, p_status);
        if (p_status = 0) then
          SequencedInsertAccOwnership (p_id_owner, p_id_owned, p_id_relation_type, 
							p_percent, p_vt_start, p_vt_end, p_tt_current, p_tt_max, p_status);
        END if;
        end;
				