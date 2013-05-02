
	SELECT
		id_agr_template AgreementTemplateId,
		n_template_name AgreementTemplateNameId,
		nm_template_name AgreementTemplateName,
		n_template_description AgreementTemplateDescId,
		nm_template_description AgreementTemplateDescription,
		created_date CreatedDate,
		created_by CreatedBy,
		updated_date UpdatedDate,
		updated_by UpdatedBy,
		available_start_date AvailableStartDate,
		available_end_date AvailableEndDate
	FROM t_agr_template
