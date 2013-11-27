
           create or replace procedure InsertAuditEvent (temp_id_userid number, temp_id_event number,
            temp_id_entity_type number, temp_id_entity number, temp_dt_timestamp date, temp_id_audit number, temp_tx_details varchar2, tx_logged_in_as nvarchar2, tx_application_name nvarchar2) as
            begin
                insert into t_audit values(temp_id_audit, temp_id_event, temp_id_userid, temp_id_entity_type, temp_id_entity, tx_logged_in_as, tx_application_name, temp_dt_timestamp);
                if (temp_tx_details is not null)
                then
                   insert into t_audit_details values(seq_t_audit_details.nextval, temp_id_audit, temp_tx_details);
                end if;
            end;
        	