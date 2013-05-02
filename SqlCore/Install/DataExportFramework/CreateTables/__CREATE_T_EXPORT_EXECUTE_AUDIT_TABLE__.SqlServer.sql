
      CREATE TABLE [t_export_execute_audit](
	      [id_audit] [int] IDENTITY(1,1) NOT NULL,
	      [id_work_queue] [char] (36) NULL,
	      [id_rep] [int] NULL,
	      [id_rep_instance_id] [int] NULL,
	      [id_schedule] [int] NULL,
	      [c_sch_type] [varchar](10) NULL,
	      [dt_queued] [datetime] NULL,
	      [dt_sched_run] [datetime] NULL,
	      [c_use_database] [varchar](50) NOT NULL,
	      [c_rep_title] [varchar](50) NOT NULL,
	      [c_rep_type] [varchar](50) NOT NULL,
	      [c_rep_def_source] [varchar](100) NULL,
	      [c_rep_query_source] [varchar](100) NULL,
	      [c_rep_query_tag] [varchar](100) NULL,
	      [c_rep_output_type] [varchar](10) NULL,
	      [c_xmlConfig_loc] [varchar](255) NULL,
	      [c_rep_distrib_type] [varchar](50) NULL,
	      [c_rep_destn] [varchar](500) NULL,
	      [c_destn_access_user] [varchar](50) NULL,
	      [c_exec_type] [char](10) NULL,
	      [c_processed_server] [varchar](50) NULL,
	      [c_eop_step_instance_name] [nvarchar](510) NULL,
	      [c_generate_control_file] [bit] NULL,
	      [c_control_file_delivery_location] [varchar](255) NULL,
	      [c_compressreport] [bit] NULL,
	      [c_compressthreshold] [int] NULL,
	      [c_output_execute_params_info] [bit] NULL,
	      [c_use_quoted_identifiers] [bit] NOT NULL CONSTRAINT [DF_t_export_execute_audit_c_use_quoted_identifiers]  DEFAULT (0),
	      [c_ds_id] [int] NULL,
	      [id_run] [int] NULL,
	      [run_start_dt] [datetime] NOT NULL,
	      [run_end_dt] [datetime] NOT NULL,
	      [c_run_result_status] [varchar](50) NOT NULL,
	      [c_run_result_descr] [varchar](2000) NULL,
	      [c_execute_paraminfo] [varchar](1000) NOT NULL,
	      [c_execution_backedout] [int] NOT NULL CONSTRAINT [DF_t_export_execute_audit_c_execution_backedout]  DEFAULT (0),
	      [c_queuerow_source] [varchar](100) NOT NULL,
	      [c_output_file_name] [varchar](50) NULL,
       CONSTRAINT [PK_t_export_execute_audit] PRIMARY KEY CLUSTERED 
      (
	      [id_audit] ASC
      ) ON [PRIMARY]
      ) ON [PRIMARY]
      
      CREATE NONCLUSTERED INDEX [idx_t_export_execute_audit_id_rep] ON [t_export_execute_audit] 
      (
	      [id_rep] ASC,
	      [dt_queued] ASC
      ) ON [PRIMARY]
      

      CREATE NONCLUSTERED INDEX [idx_result_desc] ON [dbo].[t_export_execute_audit] 
      (
	      [c_run_result_descr] ASC
      )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
      ON [PRIMARY]
      
			 