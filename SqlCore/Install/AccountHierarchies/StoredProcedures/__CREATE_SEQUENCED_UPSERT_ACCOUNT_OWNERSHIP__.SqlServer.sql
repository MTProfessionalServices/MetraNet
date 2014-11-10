
				create procedure SequencedUpsertAccOwnership
	    	@p_id_owner int,
		    @p_id_owned int,
		    @p_id_relation_type int,
		    @p_percent int,
		    @p_vt_start datetime,
		    @p_vt_end datetime,
		    @p_tt_current datetime,
		    @p_tt_max datetime,
		    @p_status int OUTPUT
        as
        begin
          exec SequencedDeleteAccOwnership @p_id_owner, @p_id_owned, @p_vt_start, @p_vt_end, @p_tt_current, @p_tt_max, @p_status output
        if @p_status <> 0 return
        else
          exec SequencedInsertAccOwnership @p_id_owner, @p_id_owned, @p_id_relation_type, 
	      @p_percent, @p_vt_start, @p_vt_end, @p_tt_current, @p_tt_max, @p_status output
        END
				