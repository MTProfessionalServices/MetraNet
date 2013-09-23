CREATE OR REPLACE
PROCEDURE arch_q_p_rollback_next_prtn(
    p_id_partition			INT,
    p_partition_field_name	VARCHAR2
)
AUTHID CURRENT_USER
AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Exception occured on execution "arch_q_p_apply_next_partition" SP. Rollback newly created partition...');

    DELETE FROM t_archive_queue_partition
	WHERE current_id_partition = p_id_partition;

    FOR x IN (  SELECT   nm_table_name
                FROM     t_service_def_log
                ORDER BY nm_table_name)
    LOOP
        arch_q_p_rollback_single_tab(
            P_TABLE_NAME => x.nm_table_name,
            P_ID_PARTITION => p_id_partition,
            P_PARTITION_FIELD_NAME => p_partition_field_name);
    END LOOP;

    arch_q_p_rollback_single_tab(
        P_TABLE_NAME => 't_message',
        P_ID_PARTITION => p_id_partition,
        P_PARTITION_FIELD_NAME => p_partition_field_name);

    arch_q_p_rollback_single_tab(
        P_TABLE_NAME => 't_session',
        P_ID_PARTITION => p_id_partition,
        P_PARTITION_FIELD_NAME => p_partition_field_name);

    arch_q_p_rollback_single_tab(
        P_TABLE_NAME => 't_session_set',
        P_ID_PARTITION => p_id_partition,
        P_PARTITION_FIELD_NAME => p_partition_field_name);

    arch_q_p_rollback_single_tab(
        P_TABLE_NAME => 't_session_state',
        P_ID_PARTITION => p_id_partition,
        P_PARTITION_FIELD_NAME => p_partition_field_name);

EXCEPTION
  WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE( 'Rollback of newly created partition is failed.
This tasks should be done manually for t_session, t_session_set, t_session_state,t_message and all t_svc_* tables:
1. Ensure Default values of "id_partition" field is "' || (p_id_partition - 1) || '";
2. Drop partition "P' || p_id_partition || '" with moving data to partition "P' || p_id_partition || '";
3. Run: DELETE FROM t_archive_queue_partition WHERE current_id_partition = '|| p_id_partition);
	RAISE;
END;
