	CREATE PROC CreateAgrTemplate
		@n_template_name				 INT,
		@nm_template_name				NVARCHAR(255),
		@n_template_description  INT = null,
		@nm_template_description NVARCHAR(255) = null,
		@created_date            DATETIME,
		@created_by              INT,
		@available_start_date    DATETIME = null,
		@available_end_date			DATETIME = null,
		@template_status				 NVARCHAR(2) = "IN",
		@id_agr_template 				INT OUTPUT
		AS

		INSERT INTO t_agr_template (n_template_name, nm_template_name, n_template_description,
                nm_template_description, created_date, created_by, updated_date, updated_by,
                available_start_date, available_end_date)
    VALUES (@n_template_name, @nm_template_name, @n_template_description, 
								@nm_template_description, @created_date, @created_by, NULL, NULL, 
								@available_start_date, @available_end_date);
    SELECT @id_agr_template = @@identity;
	  INSERT INTO t_agr_properties (id_agr_template, effective_start_date, effective_end_date)
		VALUES (@id_agr_template, null, null);
