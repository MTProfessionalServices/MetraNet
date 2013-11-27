
               CREATE TABLE t_export_reports
              (
                id_rep NUMBER(10,0)  NOT NULL,
                c_report_title VARCHAR2(50)  NOT NULL,
                c_rep_type VARCHAR2(50)  NOT NULL,
                c_rep_def_source VARCHAR2(100)  ,                
                c_rep_query_tag VARCHAR2(100)  ,
                c_report_desc VARCHAR2(255)  ,
                c_prevent_adhoc_execution NUMBER(10,0) DEFAULT (0),
                CONSTRAINT PK_t_export_reports PRIMARY KEY(id_rep)
              )
			 