CREATE OR REPLACE
PROCEDURE arch_q_p_apply_next_partition(
    p_new_current_id_partition		INT,
    p_current_time					DATE,
    p_meter_tablespace_name			VARCHAR2,
    p_meter_partition_field_name	VARCHAR2
)
AUTHID CURRENT_USER
AS
BEGIN
    
    DBMS_OUTPUT.PUT_LINE(
    'Begin execution of "archive_queue_partition_apply_next_partition"...');

    FOR x IN (  SELECT   nm_table_name
                FROM     t_service_def_log
                ORDER BY nm_table_name)
    LOOP
        arch_q_p_next_part_single_tab(
            P_TABLE_NAME => x.nm_table_name,
            P_ID_PARTITION => p_new_current_id_partition,
            P_TABLESPACE_NAME => p_meter_tablespace_name,
            P_PARTITION_FIELD_NAME => p_meter_partition_field_name);
    END LOOP;

    arch_q_p_next_part_single_tab(
        P_TABLE_NAME => 't_message',
        P_ID_PARTITION => p_new_current_id_partition,
        P_TABLESPACE_NAME => p_meter_tablespace_name,
        P_PARTITION_FIELD_NAME => p_meter_partition_field_name);

    arch_q_p_next_part_single_tab(
        P_TABLE_NAME => 't_session_set',
        P_ID_PARTITION => p_new_current_id_partition,
        P_TABLESPACE_NAME => p_meter_tablespace_name,
        P_PARTITION_FIELD_NAME => p_meter_partition_field_name);

    arch_q_p_next_part_single_tab(
        P_TABLE_NAME => 't_session',
        P_ID_PARTITION => p_new_current_id_partition,
        P_TABLESPACE_NAME => p_meter_tablespace_name,
        P_PARTITION_FIELD_NAME => p_meter_partition_field_name);

    arch_q_p_next_part_single_tab(
        P_TABLE_NAME => 't_session_state',
        P_ID_PARTITION => p_new_current_id_partition,
        P_TABLESPACE_NAME => p_meter_tablespace_name,
        P_PARTITION_FIELD_NAME => p_meter_partition_field_name);

    /* Update Default id_partition in [t_archive_queue_partition] table */
    INSERT INTO t_archive_queue_partition
    VALUES
      (
        p_new_current_id_partition,
        p_current_time,
        NULL
      );
    
    COMMIT;
    
    EXCEPTION
      WHEN OTHERS THEN
        arch_q_p_rollback_next_prtn(
			P_ID_PARTITION => p_new_current_id_partition,
			P_PARTITION_FIELD_NAME => p_meter_partition_field_name);
		RAISE;
END;
