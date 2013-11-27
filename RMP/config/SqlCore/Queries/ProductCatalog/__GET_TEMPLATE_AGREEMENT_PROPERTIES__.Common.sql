
	SELECT
		effective_start_date EffectiveStartDate,
		effective_end_date EffectiveEndDate
	FROM t_agr_properties
	WHERE
		id_agr_template = @id_agr_template
 