CREATE PROCEDURE prtn_insert_meter_partition_info
	@id_partition INT,
	@current_datetime DATETIME = NULL
AS
	SET NOCOUNT ON
	DECLARE @next_allow_run DATETIME
	
	IF @current_datetime IS NULL
	    SET @current_datetime = GETDATE()
	EXEC prtn_GetNextAllowRunDate @current_datetime = @current_datetime,
	     @next_allow_run_date = @next_allow_run OUT
	INSERT INTO t_archive_queue_partition
	VALUES
	  (
	    @id_partition,
	    @current_datetime,
	    @next_allow_run
	  )
