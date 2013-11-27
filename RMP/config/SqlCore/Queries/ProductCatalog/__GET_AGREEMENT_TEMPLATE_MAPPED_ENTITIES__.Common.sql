	SELECT
		bp.id_prop EntityId,
  	emap.entity_type EntityType,
		bp.nm_display_name EntityName
	FROM t_agr_template_entity_map emap
	INNER JOIN t_po po ON emap.id_entity = po.id_po AND emap.entity_type = 0
	INNER JOIN t_base_props bp ON po.id_po = bp.id_prop
	WHERE emap.id_agr_template = @ID_TEMPLATE