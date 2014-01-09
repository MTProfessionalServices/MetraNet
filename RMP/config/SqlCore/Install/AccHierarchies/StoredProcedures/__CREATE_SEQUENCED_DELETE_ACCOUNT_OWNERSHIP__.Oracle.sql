
				CREATE  or replace procedure SequencedDeleteAccOwnership
		(p_id_owner	int,
		p_id_owned	int,
		p_vt_start	date,
		p_vt_end	date,
		p_tt_current	TIMESTAMP,
		p_tt_max	TIMESTAMP,
		p_status OUT int)
		as
		begin
    p_status := 0;
    INSERT INTO t_acc_ownership(id_owner, id_owned, id_relation_type, n_percent,  vt_start, vt_end, tt_start, tt_end) 
    SELECT id_owner, id_owned, id_relation_type, n_percent, (p_vt_end + INTERVAL '1' SECOND) AS vt_start, vt_end, p_tt_current as tt_start, p_tt_max as tt_end
        FROM t_acc_ownership 
        WHERE id_owner = p_id_owner AND id_owned = p_id_owned
	  AND vt_start < p_vt_start AND vt_end > p_vt_end and tt_end = p_tt_max;
	    /* Valid time update becomes bi-temporal insert and update */
      INSERT INTO t_acc_ownership(id_owner, id_owned, id_relation_type, n_percent,  vt_start, vt_end, tt_start, tt_end) 
      SELECT id_owner, id_owned, id_relation_type, n_percent, vt_start, (p_vt_start - INTERVAL '1' SECOND) AS vt_end, p_tt_current AS tt_start, p_tt_max AS tt_end 
      FROM t_acc_ownership 
	    WHERE id_owner = p_id_owner AND id_owned = p_id_owned
	    AND vt_start < p_vt_start AND vt_end >= p_vt_start AND tt_end = p_tt_max;
      
      UPDATE t_acc_ownership SET tt_end = p_tt_current
	    WHERE id_owner = p_id_owner AND id_owned = p_id_owned
	    AND vt_start < p_vt_start AND vt_end >= p_vt_start AND tt_end = p_tt_max;
	    /* Valid time update becomes bi-temporal insert (of the modified existing history into the past history) and update (of the modified existing history) */
      INSERT INTO t_acc_ownership(id_owner, id_owned, id_relation_type, n_percent,  vt_start, vt_end, tt_start, tt_end)
      SELECT  id_owner, id_owned, id_relation_type, n_percent, (p_vt_end + INTERVAL '1' SECOND) AS vt_start, vt_end, p_tt_current AS tt_start, p_tt_max AS tt_end 
      FROM t_acc_ownership 
	    WHERE id_owner = p_id_owner AND id_owned = p_id_owned
	    AND vt_start <= p_vt_end AND vt_end > p_vt_end AND tt_end = p_tt_max;

      UPDATE t_acc_ownership SET tt_end = p_tt_current 
      WHERE id_owner = p_id_owner AND id_owned = p_id_owned
      AND vt_start <= p_vt_end AND vt_end > p_vt_end AND tt_end = p_tt_max;
      /*-- Now we delete any interval contained entirely in the interval we are deleting.
       Transaction table delete is really an update of the tt_end
         [----------------]                 (interval that is being modified)
       [------------------------]           (interval we are deleting) */
      UPDATE t_acc_ownership SET tt_end = p_tt_current
      WHERE id_owner = p_id_owner AND id_owned = p_id_owned
	    AND vt_start >= p_vt_start AND vt_end <= p_vt_end AND tt_end = p_tt_max;
      exception
				when others then null;	
      end;
				