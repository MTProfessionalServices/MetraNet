
create procedure SequencedDeleteGsubRecur 
			@p_id_group_sub int,
			@p_id_prop int,
			@p_vt_start datetime,
			@p_vt_end datetime,
			@p_tt_current datetime,
			@p_tt_max datetime,
			@p_status int OUTPUT
		as
		begin
		  SET @p_status = 0
      INSERT INTO t_gsub_recur_map(id_prop, id_group, id_acc, vt_start, vt_end, tt_start, tt_end) 
        SELECT id_prop, id_group, id_acc, dateadd(s,1,@p_vt_end) AS vt_start, vt_end, @p_tt_current as tt_start, @p_tt_max as tt_end
        FROM t_gsub_recur_map 
        WHERE id_prop = @p_id_prop AND id_group = @p_id_group_sub AND vt_start < @p_vt_start AND vt_end > @p_vt_end and tt_end = @p_tt_max;
      IF @@error <> 0
      BEGIN
        SET @p_status = @@error
        return
      END
      if (@p_vt_start <> dbo.mtmindate())
      begin
				-- Valid time update becomes bi-temporal insert and update
				INSERT INTO t_gsub_recur_map(id_prop, id_group, id_acc, vt_start, vt_end, tt_start, tt_end) 
				SELECT id_prop, id_group, id_acc, vt_start, dateadd(s,-1,@p_vt_start) AS vt_end, @p_tt_current AS tt_start, @p_tt_max AS tt_end 
				FROM t_gsub_recur_map WHERE id_prop = @p_id_prop AND id_group = @p_id_group_sub AND vt_start < @p_vt_start AND vt_end >= @p_vt_start AND tt_end = @p_tt_max;
					UPDATE t_gsub_recur_map SET tt_end = dateadd(s, -1, @p_tt_current) WHERE id_prop = @p_id_prop AND id_group = @p_id_group_sub AND vt_start < @p_vt_start AND vt_end >= @p_vt_start AND tt_end = @p_tt_max;
				IF @@error <> 0
				BEGIN
					SET @p_status = @@error
					return
				END
      end
			-- Valid time update becomes bi-temporal insert (of the modified existing history into the past history) and update (of the modified existing history)
      INSERT INTO t_gsub_recur_map(id_prop, id_group, id_acc, vt_start, vt_end, tt_start, tt_end) 
      SELECT id_prop, id_group, id_acc, dateadd(s,1,@p_vt_end) AS vt_start, vt_end, @p_tt_current AS tt_start, @p_tt_max AS tt_end 
      FROM t_gsub_recur_map WHERE id_prop = @p_id_prop AND id_group = @p_id_group_sub AND vt_start <= @p_vt_end AND vt_end > @p_vt_end AND tt_end = @p_tt_max;
      UPDATE t_gsub_recur_map SET tt_end = dateadd(s, -1, @p_tt_current) WHERE id_prop = @p_id_prop AND id_group = @p_id_group_sub AND vt_start <= @p_vt_end AND vt_end > @p_vt_end AND tt_end = @p_tt_max;
      IF @@error <> 0
      BEGIN
        SET @p_status = @@error
        return
      END
      -- Now we delete any interval contained entirely in the interval we are deleting.
      -- Transaction table delete is really an update of the tt_end
      --   [----------------]                 (interval that is being modified)
      -- [------------------------]           (interval we are deleting)
      UPDATE t_gsub_recur_map SET tt_end = dateadd(s, -1, @p_tt_current)
      WHERE id_prop = @p_id_prop AND id_group = @p_id_group_sub AND vt_start >= @p_vt_start AND vt_end <= @p_vt_end AND tt_end = @p_tt_max;
      IF @@error <> 0
      BEGIN
        SET @p_status = @@error
        return
      END
		end
		