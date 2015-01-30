SELECT DISTINCT(capMapper.id_acc), capMapper.id_Partition 
  FROM (

/* accounts that have the Application Logon to MAM capability */  
  SELECT 	  	
	prp.id_acc 
	,acc.id_acc AS id_Partition
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

UNION ALL

/* accounts that are assigned a role which includes Application Logon to MAM capability */
SELECT 		
	prp.id_acc  
	,acc.id_acc AS id_Partition
FROM     
	T_PRINCIPAL_POLICY prp    
	LEFT OUTER JOIN t_policy_role pr ON prp.id_policy = pr.id_policy
	LEFT OUTER JOIN t_role r ON r.id_role = pr.id_role
	LEFT OUTER JOIN t_account_ancestor accancestor ON accancestor.id_descendent = prp.id_acc AND num_generations = 2
	LEFT OUTER JOIN t_account acc ON acc.id_acc = accancestor.id_ancestor AND acc.id_type = 9
WHERE  1=1 
  AND prp.id_acc IS NOT NULL 
  AND prp.policy_type = 'A' 
  AND pr.id_role = (SELECT SUBR.id_role
					FROM T_ROLE SUBR
					INNER JOIN T_PRINCIPAL_POLICY SUBPRP ON SUBR.ID_ROLE = SUBPRP.ID_ROLE
					INNER JOIN t_capability_instance ci ON SUBPRP.ID_POLICY = CI.ID_POLICY
					LEFT OUTER JOIN t_enum_capability etc ON ci.id_cap_instance = etc.id_cap_instance
					LEFT OUTER JOIN t_enum_data ed ON etc.param_value = ed.id_enum_data
					where SUBR.id_role = pr.id_role AND ed.nm_enum_data = 'Global/Application/MAM')  

UNION ALL

      
   SELECT 
    app.id_acc 
	, acc.id_acc as id_Partition     
     FROM
     /* get policy ID for the account */
     T_PRINCIPAL_POLICY app
     INNER JOIN t_account_mapper am ON app.id_acc = am.id_acc
     /* get all the roles that sit on the account's policy */
     INNER JOIN T_POLICY_ROLE pr ON app.ID_POLICY = pr.ID_POLICY
     /* get definitions for these roles */
     INNER JOIN T_ROLE R ON PR.ID_ROLE = R.ID_ROLE
     /* get policies for all roles */
     /* ESR-3300  added is not null for performance */     
     INNER JOIN T_PRINCIPAL_POLICY RPP ON R.ID_ROLE = RPP.ID_ROLE
     /* get instances of capabilities that are defined on these roles */
     INNER JOIN t_capability_instance ci ON RPP.ID_POLICY = CI.ID_POLICY
     /* Part of CR 10448: JOIN back on the same table andon t_composite_capability_type */
		/* table to get parent type definitions */
		LEFT OUTER JOIN t_capability_instance parentci ON CI.ID_PARENT_CAP_INSTANCE = parentci.id_cap_instance
		LEFT OUTER JOIN t_Composite_capability_type parentcct ON parentci.id_cap_type = parentcct.id_cap_type
     /* get definitions of types for these capabilities */
     LEFT OUTER JOIN t_atomic_capability_type act ON ci.id_cap_type = act.id_cap_type
     LEFT OUTER JOIN t_Composite_capability_type cct ON ci.id_cap_type = cct.id_cap_type
     /* get all parameters */
     LEFT OUTER JOIN t_enum_capability etc ON ci.id_cap_instance = etc.id_cap_instance
     LEFT OUTER JOIN t_path_capability pc ON ci.id_cap_instance = pc.id_cap_instance
     LEFT OUTER JOIN t_decimal_capability dc ON ci.id_cap_instance = dc.id_cap_instance
	  LEFT OUTER JOIN t_account_ancestor accancestor ON accancestor.id_descendent = app.id_acc AND num_generations = 2
  LEFT OUTER JOIN t_account acc ON acc.id_acc = accancestor.id_ancestor AND acc.id_type = 9
	 WHERE 1=1
	 AND cct.tx_progid = 'Metratech.MTAllCapability' 
	 AND ci.id_parent_cap_instance IS NULL	
     AND app.policy_type = 'A'
	 

     UNION ALL
    
 
    SELECT 
     app.id_acc     
	 , acc.id_acc as id_Partition        
     FROM
     /* get policy ID for the account */
     T_PRINCIPAL_POLICY app
     INNER JOIN t_account_mapper am ON app.id_acc = am.id_acc
     /* get all the roles that sit on the account's policy */
     INNER JOIN T_POLICY_ROLE pr ON app.ID_POLICY = pr.ID_POLICY
     /* get definitions for these roles */
     INNER JOIN T_ROLE R ON PR.ID_ROLE = R.ID_ROLE
     /* get policies for all roles */
     /* ESR-3300  added is not null for performance */     
     INNER JOIN T_PRINCIPAL_POLICY RPP ON R.ID_ROLE = RPP.ID_ROLE
     /* get instances of capabilities that are defined on these roles */
     INNER JOIN t_capability_instance ci ON RPP.ID_POLICY = CI.ID_POLICY
     /* Part of CR 10448: JOIN back on the same table andon t_composite_capability_type */
		/* table to get parent type definitions */
		LEFT OUTER JOIN t_capability_instance parentci ON CI.ID_PARENT_CAP_INSTANCE = parentci.id_cap_instance
		LEFT OUTER JOIN t_Composite_capability_type parentcct ON parentci.id_cap_type = parentcct.id_cap_type
     /* get definitions of types for these capabilities */
     LEFT OUTER JOIN t_atomic_capability_type act ON ci.id_cap_type = act.id_cap_type
     LEFT OUTER JOIN t_Composite_capability_type cct ON ci.id_cap_type = cct.id_cap_type
     /* get all parameters */
     LEFT OUTER JOIN t_enum_capability etc ON ci.id_cap_instance = etc.id_cap_instance
     LEFT OUTER JOIN t_path_capability pc ON ci.id_cap_instance = pc.id_cap_instance
     LEFT OUTER JOIN t_decimal_capability dc ON ci.id_cap_instance = dc.id_cap_instance
	  LEFT OUTER JOIN t_account_ancestor accancestor ON accancestor.id_descendent = app.id_acc AND num_generations = 2
  LEFT OUTER JOIN t_account acc ON acc.id_acc = accancestor.id_ancestor AND acc.id_type = 9
     WHERE 1=1
	 AND ci.id_parent_cap_instance IS NULL
	 AND cct.tx_progid = 'Metratech.MTAllCapability'
     AND app.policy_type = 'A'

     
     UNION ALL
     
     
     SELECT 
     app.id_acc     
	 , acc.id_acc as id_Partition        
     FROM
     T_IMPERSONATE ti
      /* join t_account_mapper in order to get account id */
     INNER JOIN t_account_mapper am ON ti.id_owner = am.id_acc
     /* get policy ID for the account */
     INNER JOIN T_PRINCIPAL_POLICY app ON ti.ID_ACC  = app.ID_ACC 
     
     INNER JOIN t_capability_instance ci ON APP.ID_POLICY = CI.ID_POLICY
      /* Part of CR 10448: JOIN back on the same table andon t_composite_capability_type */
		/* table to get parent type definitions */
		LEFT OUTER JOIN t_capability_instance parentci ON CI.ID_PARENT_CAP_INSTANCE = parentci.id_cap_instance
		LEFT OUTER JOIN t_Composite_capability_type parentcct ON parentci.id_cap_type = parentcct.id_cap_type

     /* get definitions of types for these capabilities */
     LEFT OUTER JOIN t_atomic_capability_type act ON ci.id_cap_type = act.id_cap_type
     LEFT OUTER JOIN t_Composite_capability_type cct ON ci.id_cap_type = cct.id_cap_type
      /* get all parameters */
     LEFT OUTER JOIN t_enum_capability etc ON ci.id_cap_instance = etc.id_cap_instance
     LEFT OUTER JOIN t_path_capability pc ON ci.id_cap_instance = pc.id_cap_instance
     LEFT OUTER JOIN t_decimal_capability dc ON ci.id_cap_instance = dc.id_cap_instance
	 LEFT OUTER JOIN t_account_ancestor accancestor ON accancestor.id_descendent = app.id_acc AND num_generations = 2
     LEFT OUTER JOIN t_account acc ON acc.id_acc = accancestor.id_ancestor AND acc.id_type = 9     	  
     WHERE  1=1 
	 AND cct.tx_progid = 'Metratech.MTAllCapability'
     AND app.policy_type = 'A'
     

     UNION ALL
     

   SELECT 
     app.id_acc     
	 , acc.id_acc as id_Partition        
     FROM
     /* get policy ID for the account */
     T_PRINCIPAL_POLICY app
     /* join t_account_mapper in order to get account id */
     INNER JOIN t_account_mapper am ON app.id_acc = am.id_acc
     /* get instances of capabilities that are defined on this account */
     INNER JOIN t_capability_instance ci ON APP.ID_POLICY = CI.ID_POLICY
      /* Part of CR 10448: JOIN back on the same table and on t_composite_capability_type */
		/* table to get parent type definitions */
		LEFT OUTER JOIN t_capability_instance parentci ON CI.ID_PARENT_CAP_INSTANCE = parentci.id_cap_instance
		LEFT OUTER JOIN t_Composite_capability_type parentcct ON parentci.id_cap_type = parentcct.id_cap_type
     /* get definitions of types for these capabilities */
     LEFT OUTER JOIN t_atomic_capability_type act ON ci.id_cap_type = act.id_cap_type
     LEFT OUTER JOIN t_Composite_capability_type cct ON ci.id_cap_type = cct.id_cap_type
     /* get all parameters */
     LEFT OUTER JOIN t_enum_capability etc ON ci.id_cap_instance = etc.id_cap_instance
     LEFT OUTER JOIN t_path_capability pc ON ci.id_cap_instance = pc.id_cap_instance
     LEFT OUTER JOIN t_decimal_capability dc ON ci.id_cap_instance = dc.id_cap_instance
	  LEFT OUTER JOIN t_account_ancestor accancestor ON accancestor.id_descendent = app.id_acc AND num_generations = 2
  LEFT OUTER JOIN t_account acc ON acc.id_acc = accancestor.id_ancestor AND acc.id_type = 9
     WHERE  1=1
	 AND ci.id_cap_type = (SELECT id_cap_type FROM t_composite_capability_type cct where cct.tx_name = 'Unlimited Capability')
	 AND ci.id_parent_cap_instance IS NULL	 
     AND app.policy_type = 'A'     
	 )capMapper
	 where 1=1 