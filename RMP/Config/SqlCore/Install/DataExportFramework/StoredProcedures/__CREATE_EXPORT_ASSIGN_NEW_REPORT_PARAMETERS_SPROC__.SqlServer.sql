
      		CREATE PROCEDURE [Export_AssignNewReportParams]
      		@id_rep INT,
      		@id_param_name INT,
      		@descr VARCHAR(255)  = NULL
     
    		  AS
      		BEGIN
        		SET NOCOUNT ON
	      
		    	/* Assign Parameter to the report */  
			INSERT INTO t_export_report_params (id_rep, id_param_name, descr)
			VALUES		(@id_rep, @id_param_name, @descr)

        	/* Now add the default value of this parameter to all instances of this report 
               First get all the instances this report has and load them in a cursor */ 
	      
	          DECLARE @IDInstance INT
		  DECLARE @AllInstances_Cursor CURSOR
		  SET @AllInstances_Cursor = CURSOR FOR
		  SELECT id_rep_instance_id from t_export_report_instance where id_rep = @id_rep
		  OPEN @AllInstances_Cursor
		  FETCH NEXT FROM @AllInstances_Cursor INTO @IDInstance
		  WHILE @@FETCH_STATUS = 0
		  BEGIN

		  	INSERT INTO t_export_default_param_values       
        	  	SELECT eri.id_rep_instance_id id_rep_instance_id, erp.id_param_name id_param_name, 'UNDEFINED' c_param_value
			FROM t_export_report_params erp 
	        	  INNER JOIN t_export_report_instance eri ON erp.id_rep = eri.id_rep 
        		  WHERE erp.id_rep = @id_rep
	        	  and eri.id_rep_instance_id = @IDInstance
	          	and erp.id_param_name = @id_param_name
		  	and erp.id_param_name not in 
		  	(select id_param_name from t_export_default_param_values where id_rep_instance_id = @IDInstance
		  	and id_param_name = @id_param_name)

			FETCH NEXT FROM @AllInstances_Cursor INTO @IDInstance
		  END
		  CLOSE @AllInstances_Cursor
		  DEALLOCATE @AllInstances_Cursor
   
		END
	 