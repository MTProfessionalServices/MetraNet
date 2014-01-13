
		CREATE  PROCEDURE [dbo].[export_GetQueuedReportInstancs]
		@workQId 	CHAR(36) 	= NULL,
		@servername 	VARCHAR(50) 	= NULL
		AS

		SET NOCOUNT ON

		IF LEN(ISNULL(@WorkQId, '')) > 0
		BEGIN
			IF EXISTS (	SELECT		 tq.id_work_queue
			FROM		t_export_workqueue tq 
			WHERE     	tq.id_work_queue = @workQId
			AND		ISNULL(tq.c_current_process_stage, 0) = 0
			AND 		LEN(ISNULL(tq.c_processing_server, '')) = 0)
			BEGIN
				Execute export_UpdateRepWorkQExecStat @WorkQId, @servername, 1
				SELECT		 id_work_queue, ISNULL(id_rep, 0) as 'id_rep', ISNULL(id_rep_instance_id, 0) as 'id_rep_instance_id', ISNULL(id_schedule, 0) AS 'id_schedule', 
					ISNULL(c_sch_type, 'QUEUED') AS 'c_sch_type', c_rep_type, c_rep_title
				FROM		t_export_workqueue
				WHERE     	id_work_queue = @workQId
			END
		END
		ELSE
			SELECT		 id_work_queue, id_rep, id_rep_instance_id, ISNULL(id_schedule, 0) AS 'id_schedule', 
				ISNULL(c_sch_type, 'QUEUED') AS 'c_sch_type', c_rep_type, c_rep_title
			FROM		t_export_workqueue 
			WHERE     	id_work_queue = COALESCE(@workQId, id_work_queue)
			AND		ISNULL(c_current_process_stage, 0) = 0
			AND 		LEN(ISNULL(c_processing_server, '')) = 0
			/*	
			AND		(EXISTS(SELECT * FROM t_export_system_parms WHERE parm_name = 'system_suspended' and CONVERT(int, parm_value) = 0)
						OR c_exec_type = 'eop')  -- Added this to make sure EOP reports could get through even when the system is suspended.
			*/
			ORDER BY 	dt_queued
	 