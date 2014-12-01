SELECT 		
	prp.id_acc
FROM     
T_PRINCIPAL_POLICY prp     
INNER JOIN t_capability_instance ci ON prp.ID_POLICY = CI.ID_POLICY    
LEFT OUTER JOIN t_enum_capability etc ON ci.id_cap_instance = etc.id_cap_instance
WHERE 1=1 
AND prp.policy_type = 'A'
AND etc.param_value = (select id_enum_data from t_enum_data nm where nm.nm_enum_data = 'Global/Application/MAM')
AND id_acc IS NOT NULL