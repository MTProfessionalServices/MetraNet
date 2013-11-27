
	UPDATE t_agr_properties
	SET
		effective_start_date = @effective_start_date,
		effective_end_date = @effective_end_date
	WHERE
		id_agr_template = @id_agr_template
