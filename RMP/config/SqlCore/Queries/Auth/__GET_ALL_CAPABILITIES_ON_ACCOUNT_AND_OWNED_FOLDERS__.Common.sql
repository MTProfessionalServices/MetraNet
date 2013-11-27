
     SELECT 
     /* Query Tag: __GET_ALL_CAPABILITIES_ON_ACCOUNT_AND_OWNED_FOLDERS__ */
     /* this query has four UNIONs */
     /* 1. Capabilities that belong to roles that sit on the folders that this account owns */
     /* 2. Capabilities that belong to roles that sit on this account */
     /* 3. Capabilities that belong to folders that this account owns */
     /* 4. Capabilities that belong to this account */
     /* 5. Dummy join just to get account id in case of 0 capabilities */
     /* TODO: make sure to emilinate the redundancy cases where same role may be on the owned folder */
     /* and on the account itself. The best way to do this is return records with unique values in ID_CAP_INSTANCE field */
     am.id_acc AS id_actor, app.id_acc, app.id_policy AS id_acc_policy
     /* , pr.id_role */
     ,rpp.id_policy AS id_role_policy
     , R.TX_NAME, R.TX_DESC
     , CI.ID_CAP_INSTANCE
     ,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN 0
      ELSE CI.ID_PARENT_CAP_INSTANCE END ID_PARENT_CAP_INSTANCE
     ,CI.ID_CAP_TYPE
     	,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN cct.tx_progid ELSE act.tx_progid END type_progid
	 		,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN cct.tx_name ELSE act.tx_name END type_name
 		 ,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN cct.tx_desc ELSE act.tx_desc END type_desc
 		 /* Also get parent type name or NULL if it's a record for composite cap type. Part of CR 10448 fix. */
		,parentcct.tx_name parent_type_name
 		 ,etc.tx_op enumtype_capability_op
     ,etc.param_value enumtype_capability_value
     ,pc.tx_op path_capability_ops
     ,pc.param_value path_capability_value
     ,dc.tx_op decimal_capability_op
     ,dc.param_value decimal_capability_value

     FROM
     /* get owned folders for this account */
     T_IMPERSONATE ti
     /* join t_account_mapper in order to get account id */
     INNER JOIN t_account_mapper am ON ti.id_owner = am.id_acc
     /* get policy IDs for the accounts that this account owns */
     INNER JOIN T_PRINCIPAL_POLICY app ON ti.ID_ACC  = app.ID_ACC 
     /* get all the roles that sit on those policies */
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
     WHERE  %%%UPPER%%%(am.nm_login) = %%%UPPER%%%('%%NM_LOGIN%%') AND
            %%%UPPER%%%(am.nm_space) = %%%UPPER%%%('%%NAMESPACE%%')
     AND app.policy_type = 'A'
     
     UNION ALL
     
     SELECT 
     am.id_acc AS id_actor, app.id_acc, app.id_policy AS id_acc_policy
     /* , pr.id_role */
     ,rpp.id_policy AS id_role_policy
     , R.TX_NAME, R.TX_DESC
     , CI.ID_CAP_INSTANCE 
     ,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN 0
      ELSE CI.ID_PARENT_CAP_INSTANCE END ID_PARENT_CAP_INSTANCE
     ,CI.ID_CAP_TYPE
    	,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN cct.tx_progid ELSE act.tx_progid END type_progid
	 		,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN cct.tx_name ELSE act.tx_name END type_name
 		 ,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN cct.tx_desc ELSE act.tx_desc END type_desc
 		 /* Also get parent type name or NULL if it's a record for composite cap type. Part of CR 10448 fix. */
		,parentcct.tx_name parent_type_name

 		 ,etc.tx_op enumtype_capability_op
     ,etc.param_value enumtype_capability_value
     ,pc.tx_op path_capability_ops
     ,pc.param_value path_capability_value
     ,dc.tx_op decimal_capability_op
     ,dc.param_value decimal_capability_value

     
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

     WHERE  %%%UPPER%%%(am.nm_login) = %%%UPPER%%%(N'%%NM_LOGIN%%') AND
            %%%UPPER%%%(am.nm_space) = %%%UPPER%%%(N'%%NAMESPACE%%')
     AND app.policy_type = 'A'
     
     UNION ALL
     
     SELECT 
     am.id_acc AS id_actor, app.id_acc, app.id_policy AS id_acc_policy
     /* put nulls for roles (no roles in this case) */
     , NULL, NULL, NULL
     , CI.ID_CAP_INSTANCE
     ,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN 0
      ELSE CI.ID_PARENT_CAP_INSTANCE END ID_PARENT_CAP_INSTANCE
     ,CI.ID_CAP_TYPE
     ,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN cct.tx_progid ELSE act.tx_progid END type_progid
	 	  ,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN cct.tx_name ELSE act.tx_name END type_name
 		 ,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN cct.tx_desc ELSE act.tx_desc END type_desc
		 /* Also get parent type name or NULL if it's a record for composite cap type. Part of CR 10448 fix. */
		,parentcct.tx_name parent_type_name

 		 ,etc.tx_op enumtype_capability_op
     ,etc.param_value enumtype_capability_value
     ,pc.tx_op path_capability_ops
     ,pc.param_value path_capability_value
     ,dc.tx_op decimal_capability_op
     ,dc.param_value decimal_capability_value

     
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
     	  
     WHERE  %%%UPPER%%%(am.nm_login) = %%%UPPER%%%(N'%%NM_LOGIN%%') AND
            %%%UPPER%%%(am.nm_space) = %%%UPPER%%%(N'%%NAMESPACE%%')
     AND app.policy_type = 'A'
     
     UNION ALL
     
     SELECT 
     am.id_acc AS id_actor, app.id_acc, app.id_policy AS id_acc_policy
     , NULL, NULL, NULL
     , CI.ID_CAP_INSTANCE
      ,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN 0
      ELSE CI.ID_PARENT_CAP_INSTANCE END ID_PARENT_CAP_INSTANCE
     , CI.ID_CAP_TYPE
     ,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN cct.tx_progid ELSE act.tx_progid END type_progid
	 		,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN cct.tx_name ELSE act.tx_name END type_name
 		 ,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN cct.tx_desc ELSE act.tx_desc END type_desc
 		 /* Also get parent type name or NULL if it's a record for composite cap type. Part of CR 10448 fix. */
		,parentcct.tx_name parent_type_name
 		 ,etc.tx_op enumtype_capability_op
     ,etc.param_value enumtype_capability_value
     ,pc.tx_op path_capability_ops
     ,pc.param_value path_capability_value
     ,dc.tx_op decimal_capability_op
     ,dc.param_value decimal_capability_value

     
     FROM
     /* get policy ID for the account */
     T_PRINCIPAL_POLICY app
     /* join t_account_mapper in order to get account id */
     INNER JOIN t_account_mapper am ON app.id_acc = am.id_acc
     /* get instances of capabilities that are defined on this account */
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

     WHERE  %%%UPPER%%%(am.nm_login) = %%%UPPER%%%(N'%%NM_LOGIN%%') AND
            %%%UPPER%%%(am.nm_space) = %%%UPPER%%%(N'%%NAMESPACE%%')
     AND app.policy_type = 'A'

     /* The last UNION is just to get and account id in case the principal */
     /* has no capability. May be there is a better way to do it */
     UNION ALL
     
     SELECT 
     am.id_acc AS id_actor, NULL, NULL
     , NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL
		/* parent type name. Part of CR 10448 fix. */
		,NULL
     ,NULL, NULL, NULL, NULL
     /* get policy ID for the account */
     FROM
     T_ACCOUNT_MAPPER am
     WHERE  %%%UPPER%%%(am.nm_login) = %%%UPPER%%%(N'%%NM_LOGIN%%') AND
            %%%UPPER%%%(am.nm_space) = %%%UPPER%%%(N'%%NAMESPACE%%')
     
