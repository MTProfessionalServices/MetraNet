
CREATE OR REPLACE PROCEDURE InsertAuditEvent2 (
    temp_id_userid number,
    temp_id_event number,
    temp_id_entity_type number,
    temp_id_entity number,
    temp_dt_timestamp date,
    temp_tx_details varchar2,
    temp_id_audit number,
    tx_logged_in_as nvarchar2,
    tx_application_name nvarchar2,
    id_audit_out OUT number
)
AS
BEGIN
    IF (temp_id_audit IS NULL OR temp_id_audit = 0) THEN
         SELECT id_current INTO id_audit_out FROM t_current_id WHERE nm_current = 'id_audit' FOR UPDATE OF id_current;
         UPDATE t_current_id SET id_current=id_current+1 where nm_current='id_audit';
    ELSE
        id_audit_out := temp_id_audit;
    END IF;

    InsertAuditEvent(
        temp_id_userid      => temp_id_userid,
        temp_id_event       => temp_id_event,
        temp_id_entity_type => temp_id_entity_type,
        temp_id_entity      => temp_id_entity,
        temp_dt_timestamp   => temp_dt_timestamp,
        temp_id_audit       => id_audit_out,
        temp_tx_details     => temp_tx_details,
        tx_logged_in_as     => tx_logged_in_as,
        tx_application_name => tx_application_name
    );
END;

