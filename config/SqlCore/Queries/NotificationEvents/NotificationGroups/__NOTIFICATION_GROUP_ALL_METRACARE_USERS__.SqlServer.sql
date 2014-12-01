SELECT 		
	prp.id_acc, 
	acc.id_acc AS 'id_partition' 
FROM     
  T_PRINCIPAL_POLICY prp     
  INNER JOIN t_capability_instance ci ON prp.ID_POLICY = CI.ID_POLICY    
  LEFT OUTER JOIN t_enum_capability etc ON ci.id_cap_instance = etc.id_cap_instance
  LEFT OUTER JOIN t_account_ancestor accancestor ON accancestor.id_descendent = prp.id_acc AND num_generations = 2
  LEFT OUTER JOIN t_account acc ON acc.id_acc = accancestor.id_ancestor AND acc.id_type = 9
WHERE 1=1 
  AND prp.policy_type = 'A'
  AND etc.param_value = (select id_enum_data from t_enum_data nm where nm.nm_enum_data = 'Global/Application/MAM')
  AND prp.id_acc IS NOT NULL