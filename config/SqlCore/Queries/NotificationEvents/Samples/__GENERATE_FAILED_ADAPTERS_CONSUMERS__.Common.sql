SELECT 
  map.nm_login, 
  map.id_acc, 
  acc.id_acc AS id_partition 
FROM t_account_mapper map
LEFT OUTER JOIN t_account_ancestor accancestor ON accancestor.id_descendent = map.id_acc AND num_generations = 2
LEFT OUTER JOIN t_account acc ON acc.id_acc = accancestor.id_ancestor AND acc.id_type = 9
WHERE map.nm_space = 'system_user'