
      CREATE TABLE [t_export_report_instance](
	      [id_rep_instance_id] [int] IDENTITY(1,1) NOT NULL,
	      [c_rep_instance_desc] [varchar](100) NOT NULL,
	      [id_rep] [int] NOT NULL,
	      [c_report_online] [bit] NOT NULL CONSTRAINT [DF_t_export_report_instance_c_report_online]  DEFAULT (0),
	      [dt_activate] [datetime] NULL,
	      [dt_deactivate] [datetime] NULL,
	      [c_rep_output_type] [varchar](10) NULL,
	      [c_xmlConfig_loc] [varchar](255) NULL,
	      [c_rep_distrib_type] [varchar](50) NULL,
	      [c_report_destn] [varchar](500) NULL,
	      [c_destn_direct] [bit] NULL CONSTRAINT [DF_t_export_report_instance_c_destn_direct]  DEFAULT (0),
	      [c_access_user] [varchar](50) NULL,
	      [c_access_pwd] [nvarchar](2048) NULL,
	      [c_exec_type] [char](10) NULL,
	      [c_eop_step_instance_name] [nvarchar](510) NULL,
	      [c_generate_control_file] [bit] NULL,
	      [c_control_file_delivery_location] [varchar](255) NULL,
	      [c_ds_id] [int] NULL,
	      [c_compressreport] [bit] NOT NULL CONSTRAINT [DF_t_export_report_instance_c_compressreport]  DEFAULT (0),
	      [c_compressthreshold] [int] NULL CONSTRAINT [DF_t_export_report_instance_c_compressthreshold]  DEFAULT ((-1)),
	      [c_output_execute_params_info] [bit] NOT NULL CONSTRAINT [DF_t_export_report_instance_c_output_execute_params_info]  DEFAULT (0),
	      [c_use_quoted_identifiers] [bit] NOT NULL CONSTRAINT [DF_t_export_report_instance_c_use_quoted_identifiers]  DEFAULT (0),
	      [dt_last_run] [datetime] NOT NULL,
	      [dt_next_run] [datetime] NULL,
	      [c_output_file_name] [varchar](50) NULL,
       CONSTRAINT [PK_t_export_report_instance] PRIMARY KEY CLUSTERED 
      (
	      [id_rep_instance_id] ASC
      ) ON [PRIMARY]
      ) ON [PRIMARY]
			 