
		  CREATE TABLE t_export_queue_report_checks
		  (
			source VARCHAR2(20)  ,
			id_rep NUMBER(10,0)  ,
			id_rep_instance_id NUMBER(10,0)  ,
			id_query VARCHAR2(100)  ,
			log_error_delay NUMBER(10,0)  ,
			last_status VARCHAR2(500)  ,
			last_message_log_date DATE  ,
			email_a_warning NUMBER(10,0)  NOT NULL,
			email_subject NVARCHAR2(200)  ,
			email_address VARCHAR2(200)  ,
			CONSTRAINT idx_t_export_queue_report_chk UNIQUE( id_rep, id_rep_instance_id, id_query )              
		  )
		 