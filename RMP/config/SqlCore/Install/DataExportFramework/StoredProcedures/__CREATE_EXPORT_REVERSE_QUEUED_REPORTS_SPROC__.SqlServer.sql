
      CREATE PROCEDURE Export_ReverseQueuedReports
      @RunIdToReverse	INT
      AS
      BEGIN

	      DELETE FROM t_export_workqueue
	      WHERE id_run = @RunIdToReverse


	      UPDATE t_export_execute_audit SET c_execution_backedout = 1 WHERE id_run = @RunIdToReverse
      END
	 