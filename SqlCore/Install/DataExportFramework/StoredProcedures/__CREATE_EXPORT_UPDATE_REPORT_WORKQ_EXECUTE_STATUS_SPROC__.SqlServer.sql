
      CREATE PROCEDURE export_UpdateRepWorkQExecStat
      @workQId	CHAR(36),
      @servername	VARCHAR(50),
      @status		INT
      AS
      BEGIN
	      UPDATE 	t_export_workQueue SET c_current_process_stage = @status, c_processing_server = @servername
	      WHERE id_work_queue = @workQId
      END
	 