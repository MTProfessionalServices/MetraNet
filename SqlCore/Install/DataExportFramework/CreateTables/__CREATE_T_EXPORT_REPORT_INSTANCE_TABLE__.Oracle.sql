
              CREATE TABLE t_export_report_instance
              (
                id_rep_instance_id NUMBER(10,0)  NOT NULL,
                c_rep_instance_desc VARCHAR2(100)  NOT NULL,
                id_rep NUMBER(10,0)  NOT NULL,
                c_report_online NUMBER(1,0) DEFAULT (0) NOT NULL,
                dt_activate DATE  ,
                dt_deactivate DATE  ,
                c_rep_output_type VARCHAR2(10)  ,                
                c_rep_distrib_type VARCHAR2(50)  ,
                c_report_destn VARCHAR2(500)  ,
                c_destn_direct NUMBER(1,0) DEFAULT (0),
                c_access_user VARCHAR2(50)  ,
                c_access_pwd NVARCHAR2(2000)  ,
                c_exec_type CHAR(10)  ,
                c_eop_step_instance_name NVARCHAR2(510)  ,
                c_generate_control_file NUMBER(1,0)  ,
                c_control_file_delivery_locati VARCHAR2(255)  ,
                c_ds_id NUMBER(10,0)  ,
                c_compressreport NUMBER(1,0) DEFAULT (0) NOT NULL,
                c_compressthreshold NUMBER(10,0) DEFAULT ((-1)),
                c_output_execute_params_info NUMBER(1,0) DEFAULT (0) NOT NULL,
                c_use_quoted_identifiers NUMBER(1,0) DEFAULT (0) NOT NULL,
                dt_last_run DATE  NOT NULL,
                dt_next_run DATE,
                c_output_file_name VARCHAR2(50)  ,
                CONSTRAINT PK_t_export_report_instance PRIMARY KEY( id_rep_instance_id )
              )
			 