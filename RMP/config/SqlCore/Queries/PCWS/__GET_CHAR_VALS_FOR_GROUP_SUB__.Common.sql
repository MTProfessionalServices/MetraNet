
                SELECT       
				  id_scv SpecCharValId,
                  id_entity EntityId,
                  nm_value Value,
                  c_start_date StartDate,
                  c_end_date EndDate,
                  c_spec_name SpecName,
                  c_spec_type SpecType
				FROM t_char_values val
				INNER JOIN t_group_sub grpSub
				ON (val.id_entity = grpSub.id_group)
				-- It’s group subscription
				WHERE id_group = %%ID_ SUBSCRIPTION%%
            