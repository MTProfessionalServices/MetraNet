
      CREATE PROCEDURE Export_Queue_AdHocReport
      @id_rep					INT,
      @outputType				VARCHAR(5),
      @deliveryType			VARCHAR(10),
      @destn					VARCHAR(500),
      @compressReport			BIT,
      @compressThreshold		INT,
      @identifier				VARCHAR(100) = NULL,
      @paramNameValues		VARCHAR(1000) = NULL,
      @ftpUser				VARCHAR(50) = NULL,
      @ftpPassword			NVARCHAR(2048) = NULL,
      @createControlFile		BIT,
      @controlFileDestn		VARCHAR(500),
      @outputExecParamsInfo	BIT,
      @dsid					VARCHAR(10),
      @outputFileName			VARCHAR(50),
      @usequotedidentifiers	BIT = NULL,
      @system_datetime DATETIME
      AS
      BEGIN
      SET NOCOUNT ON
	
	      DECLARE	@reptitle VARCHAR(255), @repType VARCHAR(10), @repQuerySource VARCHAR(100), 
			      @repQueryTag VARCHAR(100), @xmlConfigLoc VARCHAR(255), @saveStatus  INT, 
			      @msg VARCHAR(255), @cRepDefSource VARCHAR(500)
			
	      SELECT  @reptitle = c_report_title, 
				  @repType = c_rep_type, 
				  @repQuerySource = c_rep_query_source, 
			      @repQueryTag = c_rep_query_tag, 
			      @xmlConfigLoc = 'DataExport\config\fieldDef',
			      @cRepDefSource = c_rep_def_source
	      FROM	t_export_reports 
	      WHERE	id_rep = @id_rep

	      INSERT INTO t_export_workqueue (  id_rep, dt_queued, dt_sched_run, c_use_database, 
				      c_rep_title, c_rep_type, c_rep_query_source, c_rep_def_source, dt_last_run, dt_next_run, 
				      c_use_quoted_identifiers, c_rep_query_tag, c_rep_output_type, c_xmlConfig_loc, 
				      c_rep_distrib_type, c_rep_destn, c_destn_direct, c_destn_access_user, c_destn_access_pwd, 
				      c_exec_type, c_generate_control_file, c_control_file_delivery_location, 
		                      c_compressreport, c_compressthreshold, c_output_execute_params_info, c_ds_id, c_queuerow_source,
                		      c_param_name_values, c_output_file_name)
	
	      VALUES			(@id_rep, @system_datetime, @system_datetime, '(local)', 
				      @reptitle, @repType, @repQuerySource, @cRepDefSource, @system_datetime -1, @system_datetime, 
				      ISNULL(@usequotedidentifiers, 0), @repQueryTag, @outputType, @xmlConfigLoc, 
				      @deliveryType, @destn, 0, @ftpuser, @ftpPassword, 
				      'ad-hoc', @createControlFile, @controlFileDestn, 
				      @compressReport, @compressThreshold, @outputExecParamsInfo, @dsid, @identifier,
				      REPLACE(@paramNameValues, '^', '%'), @outputFileName)
	
	      IF @@ERROR <> 0
		      GOTO ERR_

		      SELECT	@saveStatus = 1,
				      @msg = 'Success'
		      GOTO EXIT_SP_
		
		      RETURN

      ERR_:
		      SELECT	@saveStatus = -1,
				      @msg = 'Queue Ad-hoc report failed'

      EXIT_SP_:
      SET NOCOUNT OFF
	      SELECT @saveStatus as 'SaveStatus', @msg as 'Message'
	      RETURN
      END
	 