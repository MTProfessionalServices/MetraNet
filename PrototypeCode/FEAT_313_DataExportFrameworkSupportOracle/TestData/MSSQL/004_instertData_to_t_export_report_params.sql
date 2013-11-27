INSERT INTO t_export_report_params
           (id_param_name
           ,id_rep
           ,descr)
     VALUES
           ((SELECT TOP(1) id_param_name from t_export_param_names where c_param_name = N'%%Param1%%')
           ,(select TOP(1) id_rep from t_export_reports WHERE c_report_title='Report3-EOPWithParams')
           ,'some description')
           
INSERT INTO t_export_report_params
           (id_param_name
           ,id_rep
           ,descr)
     VALUES
           ((SELECT TOP(1) id_param_name from t_export_param_names where c_param_name = N'%%Param2%%')
           ,(select TOP(1) id_rep from t_export_reports WHERE c_report_title='Report3-EOPWithParams')
           ,'some description')