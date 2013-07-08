whenever sqlerror exit 2;

DECLARE
BEGIN
	
INSERT ALL
	INTO t_export_param_names
           (c_param_name
           ,c_param_desc)
     VALUES
           (N'%%Param1%%', N'Desc_param_1')
           
	INTO t_export_param_names
           (c_param_name
           ,c_param_desc)
     VALUES
           (N'%%Param2%%', N'Desc_param_2')        
 
SELECT * FROM dual;
COMMIT;           
END;
 /