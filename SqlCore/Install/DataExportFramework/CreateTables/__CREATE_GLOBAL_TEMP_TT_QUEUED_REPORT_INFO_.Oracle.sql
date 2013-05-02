
			 CREATE GLOBAL TEMPORARY TABLE tt_QueuedReportInfo
			(
				c_rep_title                    VARCHAR2(50 BYTE) NOT NULL,
				c_rep_type                     VARCHAR2(50 BYTE) NOT NULL,
				c_rep_def_source               VARCHAR2(100 BYTE),
				c_rep_query_source             VARCHAR2(100 BYTE),
				c_rep_query_tag                VARCHAR2(100 BYTE),
				c_rep_output_type              VARCHAR2(10 BYTE),
				c_rep_distrib_type             VARCHAR2(50 BYTE),
				c_rep_destn                    VARCHAR2(500 BYTE),
				c_destn_direct                 NUMBER,
				c_destn_access_user            VARCHAR2(50 BYTE),
				c_destn_access_pwd             NVARCHAR2(2000),
				c_generate_control_file        NUMBER(1,0),
				c_control_file_delivery_locati VARCHAR2(255 BYTE),
				c_exec_type                    CHAR(10 BYTE),
				c_compressreport               NUMBER(1,0),
				c_compressthreshold            NUMBER,
				c_ds_id                        NUMBER,
				c_eop_step_instance_name       NVARCHAR2(510),
				dt_last_run                    DATE NOT NULL,
				dt_next_run                    DATE,
				c_output_execute_params_info   NUMBER(1,0),
				c_use_quoted_identifiers       NUMBER(1,0),
				id_rep_instance_id             NUMBER(10,0),
				id_schedule                    NUMBER(10,0),
				c_sch_type                     VARCHAR2(10 BYTE),
				dt_sched_run                   DATE,
				c_param_name_values            VARCHAR2(1000 BYTE),
				c_xmlconfig_loc                VARCHAR2(255 BYTE),
				c_output_file_name             VARCHAR2(50 BYTE),
				id_work_queue                  RAW(16) NOT NULL,
				dt_queued                      DATE,
				control_file_data_date         VARCHAR2(10 BYTE)
			)
			ON COMMIT PRESERVE ROWS
       