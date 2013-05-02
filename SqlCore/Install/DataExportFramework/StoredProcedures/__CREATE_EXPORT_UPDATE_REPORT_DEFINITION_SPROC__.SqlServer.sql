
      CREATE PROCEDURE Export_UpdateReportDefinition
      @id_rep 						INT,      
      @c_rep_type         			VARCHAR(50),
      @c_report_desc				VARCHAR(255)	= NULL,
      @c_rep_def_source   			VARCHAR(100)	= NULL,
      @c_rep_query_source			VARCHAR(100)	= NULL,
      @c_rep_query_tag    			VARCHAR(100)	= NULL,
      @c_prevent_adhoc_execution	INT				= NULL
      AS
      BEGIN
	      SET NOCOUNT ON

	      declare @c_report_title VARCHAR(255)
	
	      SELECT @c_report_title = c_report_title 
	      FROM t_export_reports WHERE id_rep = @id_rep
	
	      UPDATE 	t_export_reports SET
		      c_rep_type					= @c_rep_type, 
		      c_report_desc				= ISNULL(@c_report_desc, @c_report_title),
		      c_rep_def_source			= @c_rep_def_source, 
		      c_rep_query_source			= 'DataExport\Config\queries', /* @c_rep_query_source*/ 
		      c_rep_query_tag				= @c_rep_query_tag,
		      c_prevent_adhoc_execution	= @c_prevent_adhoc_execution
	      WHERE 	id_rep = @id_rep

	      SELECT @id_rep AS 'saveStatus', 'Success' as 'StatusMessage'
      END

	 