
	SELECT bp.id_prop EntityId,
		0 EntityType,
		bp.nm_display_name EntityName
	FROM t_po po
	INNER JOIN t_base_props bp on po.id_po = bp.id_prop
	/*UNION*/ /* The following query will be replaced by another entity like RME*/
	/*SELECT bp.id_prop EntityId,
		1 EntityType,
		bp.nm_display_name EntityName
	FROM t_po po
	INNER JOIN t_base_props bp on po.id_po = bp.id_prop*/
