
      CREATE PROCEDURE [Export_UpdateReportInstance]
      @id_rep					INT,
      @ReportInstanceId		INT,
      @desc					VARCHAR(100),
      @outputType				VARCHAR(10),
      @distributionType		VARCHAR(50),
      @destination			VARCHAR(500),
      @ReportExecutionType	CHAR(10),
      @xmlConfigLocation		VARCHAR(255)	= NULL,
      @dtActivate				DATETIME		= NULL,
      @dtDeActivate			DATETIME		= NULL,
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
      @outputFileName			VARCHAR(50)		= NULL,
      @paramDefaultNameValues	VARCHAR(500)	= NULL
      AS
      BEGIN
	      SET NOCOUNT ON
	      BEGIN TRAN
	      DECLARE @ErrorMessage VARCHAR(100)
		  
	      SET @xmlConfigLocation = '\DataExport\Config\fieldDef'

	      UPDATE	t_export_report_instance SET
			      c_rep_instance_desc					= @desc,
			      dt_activate							= @dtActivate,
			      dt_deactivate						= @dtDeactivate,
			      c_rep_output_type					= @outputType,
			      c_xmlConfig_loc						= @xmlConfigLocation, 
			      c_rep_distrib_type					= @distributionType, 
			      c_report_destn						= @destination, 
			      c_access_user						= @destnAccessUser, 
			      c_access_pwd						= @destnAccessPwd, 
			      c_generate_control_file				= @createcontrolfile, 
			      c_control_file_delivery_location	= @controlfiledelivery, 
			      c_output_execute_params_info		= @outputExecuteParams,
			      c_use_quoted_identifiers			= @UseQuotedIdentifiers, 
			      c_exec_type							= @ReportExecutionType, 
			      c_compressreport					= @compressreport, 
			      c_compressthreshold					= @compressthreshold, 
			      c_ds_id								= @ds_id, 
			      c_eop_step_instance_name			= @eopinstancename, 
			      /* dt_last_run							= @dtLastRunDateTime, */ 
			      dt_next_run							= @dtNextRunDateTime,
			      c_output_file_name					= @outputFileName
	      WHERE	id_rep_instance_id = @ReportInstanceId
	

		/* Insert parameter default values if there is not one already... */
		
		/* DONT know why we have tio update the assigned parameters?
		* INSERT INTO t_export_default_param_values       
          	SELECT @ReportInstanceId id_rep_instance_id, erp.id_param_name id_param_name, 'UNDEFINED' c_param_value
          	FROM t_export_report_params erp 
          	where erp.id_rep = @id_rep
            and erp.id_param_name not in 
            (select id_param_name from t_export_default_param_values where id_rep_instance_id = @ReportInstanceId)*/
          
     
     GOTO EXIT_SUCCESS_ 

      ERROR_:
	      ROLLBACK
	      RAISERROR (@ErrorMessage, 16, 1)
	      RETURN
      EXIT_SUCCESS_:
	      COMMIT TRAN
	      RETURN 0
      END
	 