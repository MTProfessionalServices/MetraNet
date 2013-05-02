                                       
              CREATE OR REPLACE PROCEDURE Export_InsertReportDefinition
              (
                p_c_report_title IN VARCHAR2 DEFAULT NULL ,
                p_c_report_desc IN VARCHAR2 DEFAULT NULL ,
                p_c_rep_type IN VARCHAR2 DEFAULT NULL ,
                p_c_rep_def_source IN VARCHAR2 DEFAULT NULL ,
                p_c_rep_query_source IN VARCHAR2 DEFAULT NULL ,
                p_c_rep_query_tag IN VARCHAR2 DEFAULT NULL ,
                p_c_prevent_adhoc_execution IN NUMBER DEFAULT NULL ,
                cv_1 IN OUT SYS_REFCURSOR
              )
              AS
                 v_c_rep_query_source VARCHAR2(255) := p_c_rep_query_source;
                 v_id_rep NUMBER(10,0);
              
              BEGIN
                 INSERT INTO t_export_reports
                   ( c_report_title, c_report_desc, c_rep_type, c_rep_def_source, c_rep_query_source, c_rep_query_tag, c_prevent_adhoc_execution )
                   VALUES ( p_c_report_title, NVL(p_c_report_desc, p_c_report_title), p_c_rep_type, p_c_rep_def_source, v_c_rep_query_source, p_c_rep_query_tag, p_c_prevent_adhoc_execution )
                   RETURNING id_rep INTO v_id_rep;
                 OPEN cv_1 FOR
                    SELECT v_id_rep saveStatus  ,
                           'Success' StatusMessage  
                      FROM DUAL ;
              END;
	 