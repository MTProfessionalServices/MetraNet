
	UPDATE t_agr_template SET
		nm_template_name = @nm_template_name,
		n_template_description = @n_template_description,
		nm_template_description = @nm_template_description,
		updated_date = @updated_date,
		updated_by  = @updated_by,
		available_start_date = @available_start_date,
		available_end_date = @available_end_date
	WHERE id_agr_template = @id_agr_template
