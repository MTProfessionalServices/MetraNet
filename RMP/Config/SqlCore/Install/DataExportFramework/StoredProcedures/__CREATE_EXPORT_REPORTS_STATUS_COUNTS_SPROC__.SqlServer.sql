
      CREATE PROCEDURE Export_ReportsStatusCounts
      @start_dt	DATETIME,
      @end_dt		DATETIME
      AS
      BEGIN
	      SET NOCOUNT ON
	
	      DECLARE @successCount INT, @failedCount INT
	
	
	      SELECT		@successCount = COUNT(*) 
	      FROM		t_export_execute_audit
	      WHERE		run_end_dt >= @start_dt AND run_end_dt < @end_dt
	      AND			c_run_result_status = 'success'

	      SELECT		@failedCount = COUNT(*) 
	      FROM		t_export_execute_audit 
	      WHERE		run_end_dt >= @start_dt AND run_end_dt < @end_dt
	      AND			c_run_result_status = 'failed'
	
	
	      SELECT @successCount as 'SUCCESS', @failedCount as 'FAILED'
	
	      RETURN
      END
	 