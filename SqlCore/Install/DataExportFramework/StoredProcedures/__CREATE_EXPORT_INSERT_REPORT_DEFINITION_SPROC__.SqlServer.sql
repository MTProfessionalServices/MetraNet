
      CREATE PROCEDURE Export_InsertReportDefinition
      @c_report_title     		VARCHAR(50),
      @c_report_desc			VARCHAR(255)	= NULL,
      @c_rep_type         		VARCHAR(50),
      @c_rep_def_source   		VARCHAR(100)	= NULL,
      @c_rep_query_source 		VARCHAR(100)	= NULL,
      @c_rep_query_tag    		VARCHAR(100)	= NULL,
      @c_prevent_adhoc_execution	INT			= NULL
      AS
      BEGIN
	      SET NOCOUNT ON
         
          DECLARE @id_rep INT

	      INSERT INTO t_export_reports (	c_report_title, c_report_desc, c_rep_type, c_rep_def_source, 
								      c_rep_query_source, c_rep_query_tag, c_prevent_adhoc_execution)
	      VALUES		(			@c_report_title, ISNULL(@c_report_desc, @c_report_title), @c_rep_type, @c_rep_def_source, 
								      @c_rep_query_source, @c_rep_query_tag, @c_prevent_adhoc_execution)	

	      SELECT @id_rep = SCOPE_IDENTITY()

	      SELECT @id_rep AS 'saveStatus', 'Success' AS 'StatusMessage'
      END
	 