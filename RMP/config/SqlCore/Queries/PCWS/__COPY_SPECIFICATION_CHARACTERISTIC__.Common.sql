
			INSERT INTO t_entity_specs
			       (id_entity, id_spec, c_display_order, entity_type)
			SELECT %%ID_NEW_ENTITY%%, id_spec, c_display_order, 0
			FROM t_entity_specs
			WHERE id_entity = %%ID_OLD_ENTITY%% AND entity_type = 0
		  