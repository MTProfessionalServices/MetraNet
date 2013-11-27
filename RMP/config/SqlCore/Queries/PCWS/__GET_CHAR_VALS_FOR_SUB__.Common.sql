
                SELECT       
				  id_scv SpecCharValId,
                  id_entity EntityId,
                  nm_value Value,
                  c_start_date StartDate,
                  c_end_date EndDate,
                  c_spec_name SpecName,
                  c_spec_type SpecType
				FROM t_char_values
				WHERE  id_entity = %%ID_SUBSCRIPTION%%	
            