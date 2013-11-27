
		    CREATE TABLE [t_export_workqueue](
	    [id_work_queue] [uniqueidentifier] NOT NULL CONSTRAINT [DF_t_export_workqueue_id_work_queue]  DEFAULT (newid()),
	    [id_rep_instance_id] [int] NULL,
	    [id_rep] [int] NULL,
	    [id_schedule] [int] NULL,
	    [c_sch_type] [varchar](10) NULL,
	    [dt_queued] [datetime] NOT NULL,
	    [dt_sched_run] [datetime] NULL,
	    [c_use_database] [varchar](50) NULL,
	    [c_rep_title] [varchar](50) NOT NULL,
	    [c_rep_type] [varchar](50) NOT NULL,
	    [c_rep_def_source] [varchar](100) NULL,
	    [c_rep_query_tag] [varchar](100) NULL,
	    [c_rep_output_type] [varchar](10) NULL,	    
	    [c_rep_distrib_type] [varchar](50) NULL,
	    [c_rep_destn] [varchar](500) NULL,
	    [c_destn_direct] [bit] NULL,
	    [c_destn_access_user] [varchar](50) NULL,
	    [c_destn_access_pwd] [nvarchar](2048) NULL,
	    [c_exec_type] [char](10) NULL,
	    [c_eop_step_instance_name] [nvarchar](510) NULL,
	    [c_generate_control_file] [bit] NULL,
	    [c_control_file_delivery_location] [varchar](255) NULL,
	    [c_compressreport] [bit] NULL,
	    [c_compressthreshold] [int] NULL,
	    [c_output_execute_params_info] [bit] NULL,
	    [c_use_quoted_identifiers] [bit] NULL CONSTRAINT [DF_t_export_workqueue_c_quoted_identifier]  DEFAULT (0),
	    [c_ds_id] [int] NULL,
	    [dt_last_run] [datetime] NOT NULL,
	    [dt_next_run] [datetime] NULL,
	    [c_current_process_stage] [int] NULL,
	    [c_processing_server] [varchar](50) NULL,
	    [c_param_name_values] [varchar](1000) NULL,
	    [id_run] [int] NULL,
	    [c_queuerow_source] [varchar](100) NULL,
	    [c_output_file_name] [varchar](50) NULL,
	    [c_id_work_queue_int] [int] IDENTITY(1,1) NOT NULL,
     CONSTRAINT [PK_t_export_workqueue] PRIMARY KEY CLUSTERED 
    (
	    [id_work_queue] ASC
    ) ON [PRIMARY]
    ) ON [PRIMARY]
			 