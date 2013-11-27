CREATE OR REPLACE
PROCEDURE arch_q_p_get_status(
    p_current_time                    DATE,
    p_next_allow_run_time       OUT   DATE,
    p_current_id_partition      OUT   INT,
    p_new_current_id_partition  OUT   INT,
    p_old_id_partition          OUT   INT,
    p_no_need_to_run            OUT   INT
)
AUTHID CURRENT_USER
AS
    message			VARCHAR2(4000);
    is_data_exist	INT;
BEGIN

    p_no_need_to_run := 0;
    
    SELECT COUNT(1) INTO is_data_exist FROM t_archive_queue_partition WHERE ROWNUM = 1;
    IF is_data_exist = 0 THEN
        raise_application_error(-20000, 't_archive_queue_partition must contain at least one record.
Try to execute "USM CREATE" command in cmd.
First record inserts to this table on creation of Partition Infrastructure for metering tables');
    END IF;
    
    SELECT MAX(current_id_partition)
	INTO p_current_id_partition
    FROM    t_archive_queue_partition;
    
    SELECT next_allow_run
	INTO p_next_allow_run_time
    FROM t_archive_queue_partition
    WHERE current_id_partition = p_current_id_partition;
    
    IF p_next_allow_run_time IS NOT NULL THEN
		BEGIN
			/* Period of full partition cycle should pass since last execution of [archive_queue_partition] */
			IF p_current_time < p_next_allow_run_time THEN
			BEGIN
				p_no_need_to_run := 1;
				DBMS_OUTPUT.PUT_LINE('No need to run archive functionality. '
					|| 'Time of cycle period not elapsed yet since the last run. '
					|| 'Try execute the procedure after "'
					|| p_next_allow_run_time || '" date.');
			END;
			END IF;

			p_new_current_id_partition  := p_current_id_partition + 1; 
			p_old_id_partition          := p_current_id_partition - 1;
		END;
    ELSE
		BEGIN
			DBMS_OUTPUT.PUT_LINE('Warning: previouse execution of [archive_queue_partition] failed.
The oldest partition was not archived, but new data already written to new partition with ID: "'
|| p_current_id_partition || '".
Retrying archivation of the oldest partition...');

			p_new_current_id_partition  := p_current_id_partition;
			p_current_id_partition      := p_new_current_id_partition - 1;
			p_old_id_partition          := p_new_current_id_partition - 2;
		END;
    END IF;
END;

