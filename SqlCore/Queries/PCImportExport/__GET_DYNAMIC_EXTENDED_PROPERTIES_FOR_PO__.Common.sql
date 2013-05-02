
				SELECT tsc.* FROM t_spec_characteristics tsc
				INNER JOIN t_entity_specs tes ON tes.id_spec = tsc.id_spec
				WHERE tes.id_entity = %%PO_ID%%
				AND tes.entity_type = 0
			