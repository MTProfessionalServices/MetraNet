SELECT     
	COUNT(*) 
FROM         t_acctype_descendenttype_map 
	INNER JOIN t_account ON t_acctype_descendenttype_map.id_type = t_account.id_type 
	INNER JOIN t_account_type ON t_acctype_descendenttype_map.id_descendent_type = t_account_type.id_type
WHERE     
	t_account.id_acc = @id_acc
	AND t_account_type.name = @descendent_type