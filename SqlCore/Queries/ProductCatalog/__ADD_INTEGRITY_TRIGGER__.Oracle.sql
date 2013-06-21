DECLARE
    trigg_name VARCHAR2(30);
BEGIN
    /* Truncate trigger name to 30 characters */
    trigg_name := 'TR_' || UPPER(SUBSTR('%%NM_NAME%%', 0, 23)) || 'IDSC';
    
    EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER ' || trigg_name ||
        ' AFTER INSERT OR UPDATE ON %%NM_NAME%% FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, ''No parent key found for record in %%NM_NAME%% table'');
    END IF;
        
END;';
END;

