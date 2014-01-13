                                    
              CREATE OR REPLACE PROCEDURE Export_UpdateReportDefinition
              (
                p_id_rep IN NUMBER DEFAULT NULL ,
                p_c_rep_type IN VARCHAR2 DEFAULT NULL ,
                p_c_report_desc IN VARCHAR2 DEFAULT NULL ,
                p_c_rep_def_source IN VARCHAR2 DEFAULT NULL ,                
                p_c_rep_query_tag IN VARCHAR2 DEFAULT NULL ,
                p_c_prevent_adhoc_execution IN NUMBER DEFAULT NULL ,
                cv_1 IN OUT SYS_REFCURSOR
              )
              AS
                 p_c_report_title VARCHAR2(50);
              
              BEGIN
                 SELECT c_report_title 
              
                   INTO p_c_report_title
                   FROM t_export_reports 
                  WHERE id_rep = p_id_rep;
                 UPDATE t_export_reports
                    SET c_rep_type = p_c_rep_type,
                        c_report_desc = NVL(p_c_report_desc, p_c_report_title),
                        c_rep_def_source = p_c_rep_def_source,                        
                        c_rep_query_tag = p_c_rep_query_tag,
                        c_prevent_adhoc_execution = p_c_prevent_adhoc_execution
                    WHERE id_rep = p_id_rep;
                 OPEN cv_1 FOR
                    SELECT p_id_rep saveStatus  ,
                           'Success' StatusMessage  
                      FROM DUAL ;
              END;
	 