IF OBJECT_ID('archive_queue_partition_get_status') IS NOT NULL 
	DROP PROCEDURE archive_queue_partition_get_status
GO

CREATE PROCEDURE archive_queue_partition_get_status(
    @current_time              DATETIME,
    @next_allow_run_time       DATETIME OUT,
    @current_id_partition      INT OUT,
    @new_current_id_partition  INT OUT,
    @old_id_partition          INT OUT,
    @no_need_to_run            BIT OUT
)
AS
	SET NOCOUNT ON
	
	DECLARE @message NVARCHAR(4000)
	SET @no_need_to_run = 0
	
	IF NOT EXISTS(SELECT * FROM t_archive_queue_partition)
	    RAISERROR ('t_archive_queue_partition must contain at least one record.
Try to execute "USM CREATE" command in cmd.
First record inserts to this table on creation of Partition Infrastructure for metering tables', 16, 1)
	
	SELECT @current_id_partition = MAX(current_id_partition)
	FROM   t_archive_queue_partition
	
	SELECT @next_allow_run_time = next_allow_run
	FROM   t_archive_queue_partition
	WHERE  current_id_partition = @current_id_partition
	
	IF @next_allow_run_time IS NULL
	BEGIN
	    SET @message = 'Warning: previouse execution of [archive_queue_partition] failed.
The oldest partition was not archived, but new data already written to new partition with ID: "'
+ CAST(@current_id_partition AS NVARCHAR(20)) + '".
Retrying archivation of the oldest partition...'
	    RAISERROR (@message, 0, 1)
	    
	    SET @new_current_id_partition = @current_id_partition
	    SET @current_id_partition = @new_current_id_partition - 1
	    SET @old_id_partition = @new_current_id_partition - 2
	END
	ELSE
	BEGIN
	    /* Period of full partition cycle should pass since last execution of [archive_queue_partition] */
	    IF (@current_time < @next_allow_run_time)
	    BEGIN
	        SET @no_need_to_run = 1
	        SET @message = 'No need to run archive functionality. '
	            + 'Time of cycle period not elapsed yet since the last run. '
	            + 'Try execute the procedure after "'
	            + CONVERT(VARCHAR, @next_allow_run_time) + '" date.'
	        RAISERROR (@message, 0, 1)
	    END
	    
		SET @new_current_id_partition = @current_id_partition + 1	
		SET @old_id_partition = @current_id_partition - 1
	END
