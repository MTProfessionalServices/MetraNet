CREATE OR REPLACE
PROCEDURE archive_queue(
    p_update_stats		VARCHAR2	DEFAULT 'N',
    p_sampling_ratio	VARCHAR2	DEFAULT '30',
    p_current_time		DATE		DEFAULT NULL,
    p_result		OUT VARCHAR2
)
AUTHID CURRENT_USER
AS
    /*
    How to run this stored procedure:   
    DECLARE 
		v_result VARCHAR2(2000);
    BEGIN
		archive_queue ( p_result => v_result );
    DBMS_OUTPUT.ENABLE(1000000);
		DBMS_OUTPUT.put_line (v_result);
    END;
    
    Or if we want to update statistics and change current date/time also:   
    DECLARE 
        v_result		VARCHAR2(2000),
        v_current_time	DATE
    BEGIN
        v_current_time := SYSDATE;
        archive_queue_partition (
             p_update_stats => 'Y',
             p_sampling_ratio => 30,
             p_current_time => v_current_time,
             p_result => v_result
             );
        DBMS_OUTPUT.put_line (v_result);
    END;
    */
    v_is_part_enabled			VARCHAR2(1);
BEGIN

    SELECT UPPER(b_partitioning_enabled) INTO v_is_part_enabled FROM t_usage_server;
    /* Nothing to do if system isn't enabled for partitioning */
    IF v_is_part_enabled <> 'Y' THEN 
        dbms_output.put_line('Partitioning is not enabled, so can not execute archive_queue sp.');
        RETURN;
    END IF;

	archive_queue_partition(
		P_UPDATE_STATS => p_update_stats,
		P_SAMPLING_RATIO => p_sampling_ratio,
		P_CURRENT_TIME => p_current_time,
		P_RESULT => p_result);
END;
