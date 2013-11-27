
CREATE PROCEDURE prtn_GetNextAllowRunDate
	@current_datetime DATETIME = NULL,
	@next_allow_run_date DATETIME OUT
AS
	SET NOCOUNT ON
	
	IF @current_datetime IS NULL
	    SET @current_datetime = GETDATE()
	
	DECLARE @days_to_add INT 
	SELECT @days_to_add = tuc.n_proration_length
	FROM   t_usage_server tus
	       INNER JOIN t_usage_cycle_type tuc
	            ON  tuc.tx_desc = tus.partition_type
	
	SET @next_allow_run_date = DATEADD(DAY, @days_to_add, @current_datetime)
	