
      CREATE PROCEDURE [dbo].[Export_CreateReportInstance]
      @id_rep					INT,
      @desc					VARCHAR(100),
      @outputType				VARCHAR(10),
      @distributionType		VARCHAR(50),
      @destination			VARCHAR(500),
      @ReportExecutionType	CHAR(10),      
      @c_report_online		BIT				= NULL,
      @dtActivate				DATETIME		= NULL,
      @dtDeActivate			DATETIME		= NULL,
      @directMoveToDestn		BIT				= NULL,
      @destnAccessUser		VARCHAR(50)		= NULL,
      @destnAccessPwd			NVARCHAR(2048)		= NULL,
      @compressreport			BIT				= NULL,
      @compressthreshold		INT 			= NULL,
      @ds_id					INT				= NULL,
      @eopinstancename		NVARCHAR(510)	= NULL,
      @createcontrolfile		BIT				= NULL,
      @controlfiledelivery	VARCHAR(255)	= NULL,
      @outputExecuteParams	BIT				= NULL,
      @UseQuotedIdentifiers	BIT				= NULL,
      @dtLastRunDateTime		DATETIME		= NULL,
      @dtNextRunDateTime		DATETIME		= NULL,
      @paramDefaultNameValues	VARCHAR(500)	= NULL,
      @outputFileName			VARCHAR(50)		= NULL,
      @system_datetime			DATETIME,
      @ReportInstanceId		INT				OUTPUT
      AS
      BEGIN 
	      SET NOCOUNT ON
	      BEGIN TRAN
	      DECLARE @ErrorMessage VARCHAR(100)
	      
	      INSERT INTO t_export_report_instance ( 
				      c_rep_instance_desc, id_rep, c_report_online, dt_activate, 
				      dt_deactivate, c_rep_output_type, c_rep_distrib_type, 
				      c_report_destn, c_destn_direct, c_access_user, c_access_pwd, 
				      c_generate_control_file, c_control_file_delivery_location, c_output_execute_params_info,
				      c_use_quoted_identifiers, c_exec_type, c_compressreport, c_compressthreshold, 
				      c_ds_id, c_eop_step_instance_name, dt_last_run, dt_next_run, c_output_file_name)
	      VALUES	(	@desc, @id_rep, ISNULL(@c_report_online, 0), ISNULL(@dtActivate, @system_datetime),
				      @dtDeActivate, @outputType, @distributionType, 
				      @destination, ISNULL(@directMoveToDestn, 1), @destnAccessUser, @destnAccessPwd, 
				      @createcontrolfile, @controlfiledelivery, ISNULL(@outputExecuteParams, 0),
				      @UseQuotedIdentifiers, @ReportExecutionType, ISNULL(@compressreport, 0), ISNULL(@compressthreshold, -1), 
				      @ds_id, @eopinstancename, @dtLastRunDateTime, @dtNextRunDateTime, @outputFileName)

	      SELECT @ReportInstanceId	= SCOPE_IDENTITY()
         /* Insert Blank Values for all Parameters associated with the report */
         
	  INSERT INTO t_export_default_param_values       
          SELECT @ReportInstanceId id_rep_instance_id, erp.id_param_name id_param_name, 'UNDEFINED' c_param_value
          FROM t_export_report_params erp 
          where erp.id_rep = @id_rep
          and NOT EXISTS (select id_param_name from t_export_default_param_values where id_rep_instance_id = @ReportInstanceId)

	 
      GOTO EXIT_SUCCESS_ 
      
      ERROR_:
	      ROLLBACK
	      RAISERROR (@ErrorMessage, 16, 1)
	      RETURN
      EXIT_SUCCESS_:
	      COMMIT TRAN
	      RETURN 0
      END
	 