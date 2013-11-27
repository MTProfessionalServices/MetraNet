
      CREATE PROCEDURE Export_ReportsExecutionHealthCheck
      @start_dt	DATETIME,
      @end_dt		DATETIME
      AS
      BEGIN

	      SELECT     c_rep_title, run_start_dt, run_end_dt, c_run_result_status, c_run_result_descr, c_sch_type, c_execute_paraminfo
	      FROM         dbo.t_export_execute_audit
	      WHERE		run_end_dt >= @start_dt AND run_end_dt < @end_dt

      END
	 