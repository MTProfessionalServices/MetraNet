
      begin
        INSERT INTO t_audit
        /* __AUDIT_ADD_OWNERSHIP__ */
        (id_audit, id_event,id_userid, id_entitytype, id_entity, dt_crt)
          SELECT tmp.id_audit, tmp.id_event, tmp.id_userid, tmp.id_entitytype, tmp.id_owned, tmp.tt_start
            FROM %%%TEMP_TABLE_PREFIX%%%tmp_acc_ownership_batch tmp
            WHERE tmp.status = 0;
        INSERT INTO t_audit_details(id_auditdetails, id_audit, tx_details)
          SELECT seq_t_audit_details.nextval, tmp.id_audit,
            'Account ' %%%CONCAT%%% CAST(tmp.id_owner AS VARCHAR(20)) %%%CONCAT%%% ' is successfully assigned as owner to account ' %%%CONCAT%%% CAST(tmp.id_owned AS VARCHAR(20)) %%%CONCAT%%% ' (part of batch operation)' 
            FROM %%%TEMP_TABLE_PREFIX%%%tmp_acc_ownership_batch tmp
            WHERE tmp.status = 0;
       end;
        