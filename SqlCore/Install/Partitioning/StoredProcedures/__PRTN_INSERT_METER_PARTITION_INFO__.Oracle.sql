CREATE OR REPLACE PROCEDURE prtn_insert_meter_part_info(
    id_partition INT,
    current_datetime DATE DEFAULT SYSDATE)
AS
    next_allow_run DATE;
BEGIN

    prtn_get_next_allow_run_date (
        current_datetime => current_datetime,
        next_allow_run_date => next_allow_run);
         
    INSERT INTO t_archive_queue_partition
    VALUES
      (
        id_partition,
        current_datetime,
        next_allow_run
      );
END;