whenever sqlerror exit 2;

DECLARE
BEGIN
	
INSERT ALL
  INTO t_export_report_params
           (id_param_name
           ,id_rep
           ,descr)
     VALUES
           ((SELECT id_param_name from t_export_param_names where c_param_name = N'%%Param1%%' and ROWNUM = 1)
           ,(select id_rep from t_export_reports WHERE c_report_title='Report3-EOPWithParams' and ROWNUM = 1 )
           ,'some description')
           
  INTO t_export_report_params
           (id_param_name
           ,id_rep
           ,descr)
     VALUES
           ((SELECT id_param_name from t_export_param_names where c_param_name = N'%%Param2%%' and ROWNUM = 1)
           ,(select id_rep from t_export_reports WHERE c_report_title='Report3-EOPWithParams' and ROWNUM = 1 )
           ,'some description')         
 
SELECT * FROM dual;
COMMIT;           
END;
 /