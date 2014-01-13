
    INSERT INTO 
      t_acc_ownership(id_owner,id_owned,id_relation_type,n_percent,vt_start,vt_end,tt_start,tt_end)	
      SELECT id_owner, id_owned, id_relation_type, 
      n_percent, vt_start, vt_end, tt_start, dbo.MTMaxDate()
      FROM %%%TEMP_TABLE_PREFIX%%%tmp_acc_ownership_batch ar
      WHERE
      ar.status=0
        