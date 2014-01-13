	CREATE OR REPLACE PROCEDURE CreateAgrTemplate(
			n_template_name         in number,
      nm_template_name        in VARCHAR,
      n_template_description  in number default NULL,
      nm_template_description in VARCHAR default NULL,
      created_date            in DATE,
      created_by              in number,
      available_start_date    in DATE default NULL,
      available_end_date      in DATE default null,
      id_agr_template         OUT NUMBER
      )

	AS
  	BEGIN 
		    INSERT INTO t_agr_template (id_agr_template, n_template_name, nm_template_name, n_template_description,
                											nm_template_description, created_date, created_by, updated_date, updated_by,
                											available_start_date, available_end_date)
        VALUES (seq_t_agr_template.NextVal, n_template_name, nm_template_name, n_template_description, 
																			nm_template_description, created_date, created_by, NULL, NULL, 
																			available_start_date, available_end_date);
				SELECT seq_t_agr_template.CurrVal into id_agr_template from dual;
				INSERT INTO t_agr_properties (id_agr_template, effective_start_date, effective_end_date)
			  VALUES (id_agr_template, null, null);
     END;
