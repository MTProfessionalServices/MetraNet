
      CREATE PROCEDURE [dbo].[Export_CreateReportDefinition]
      @c_report_title     VARCHAR(255),
      @c_rep_type         VARCHAR(10),
      @c_rep_def_source   VARCHAR(255)	= NULL,
      @c_rep_query_source VARCHAR(255)	= NULL,
      @c_rep_query_tag    VARCHAR(255)	= NULL,
      @ParameterNames     VARCHAR(5000)	= NULL,
      @id_rep             INT               OUTPUT

      AS
      BEGIN
	      SET NOCOUNT ON	      
	 
	      IF EXISTS (SELECT id_rep FROM t_export_reports WHERE c_report_title = @c_report_title)
	      BEGIN
		      SELECT @id_rep = id_rep FROM t_export_reports WHERE c_report_title = @c_report_title
		      RETURN
	      END
	
	      INSERT INTO t_export_reports (c_report_title, c_rep_type, c_rep_def_source, c_rep_query_source, c_rep_query_tag)
	      VALUES		(@c_report_title, @c_rep_type, @c_rep_def_source,@c_rep_query_source, @c_rep_query_tag)	

	      SELECT @id_rep = SCOPE_IDENTITY()
	
	      DECLARE @ipos INT, @inextpos INT, @paramname VARCHAR(100), @paramnameid INT
	      SELECT @ipos = 0, @inextpos = 0
	
	      IF LEN(ISNULL(@ParameterNames, '')) > 0
	      BEGIN
		      /* Create parameters for this report definition */
		      /* Parse the comma seperated string to get the information for this. */
		      /* fix the comma separated string if the last char is not a comma(",") */
		      SET @ParameterNames = LTRIM(@ParameterNames)
		      SET @ParameterNames = RTRIM(@ParameterNames)
		      IF SUBSTRING(@ParameterNames, LEN(@ParameterNames), 1) <> ','
			      SET @ParameterNames = @ParameterNames + ','

		      SELECT @inextpos = CHARINDEX(',', @ParameterNames, @ipos)
		      WHILE @inextpos > 0 
		      BEGIN
			      SET @paramname = SUBSTRING(@ParameterNames, @ipos, @inextpos - @ipos)
			
			      IF EXISTS (SELECT * FROM t_export_param_names WHERE c_param_name = @paramname)
				      SELECT @paramnameid = id_param_name FROM t_export_param_names WHERE c_param_name = @paramname
			      ELSE
			      BEGIN
				      INSERT INTO t_export_param_names (	c_param_name) 
				      VALUES					(		@paramname)
				      SELECT @paramnameid = SCOPE_IDENTITY()
			      END
			
			      INSERT INTO t_export_report_params (	id_param_name, id_rep)  
			      VALUES				(				@paramnameid, @id_rep)
			
			      SET @ipos = @inextpos + 1
			      SELECT @inextpos = CHARINDEX(',', @ParameterNames, @ipos)
		      END
	      END
	
	      RETURN
      END
