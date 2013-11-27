
			SELECT 
			/* Query Tag: __GET_CAPS_ON_PRINCIPAL__ */
	    prp.id_acc, prp.id_policy AS id_principal_policy
     	, CI.ID_CAP_INSTANCE
      , CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN 0
        ELSE CI.ID_PARENT_CAP_INSTANCE END ID_PARENT_CAP_INSTANCE
      , CI.ID_CAP_TYPE
    	,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN cct.tx_progid ELSE act.tx_progid END type_progid
 			,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN cct.tx_name ELSE act.tx_name END type_name
 		 ,CASE WHEN CI.ID_PARENT_CAP_INSTANCE IS NULL THEN cct.tx_desc ELSE act.tx_desc END type_desc
     ,etc.tx_op enumtype_capability_op
     ,etc.param_value enumtype_capability_value
     ,pc.tx_op path_capability_ops
     ,pc.param_value path_capability_value
     ,dc.tx_op decimal_capability_op
     ,dc.param_value decimal_capability_value
	 	 FROM
     /* get policy ID for this principal */
     T_PRINCIPAL_POLICY prp
     /* get instances of capabilities that are defined on this account */
     INNER JOIN t_capability_instance ci ON prp.ID_POLICY = CI.ID_POLICY
     /* get definitions of types for these capabilities */
     LEFT OUTER JOIN t_atomic_capability_type act ON ci.id_cap_type = act.id_cap_type
     LEFT OUTER JOIN t_composite_capability_type cct ON ci.id_cap_type = cct.id_cap_type
     /* get all parameters */
     LEFT OUTER JOIN t_enum_capability etc ON ci.id_cap_instance = etc.id_cap_instance
     LEFT OUTER JOIN t_path_capability pc ON ci.id_cap_instance = pc.id_cap_instance
     LEFT OUTER JOIN t_decimal_capability dc ON ci.id_cap_instance = dc.id_cap_instance
     WHERE prp.%%PRINCIPAL_COLUMN%% = %%ID_PRINCIPAL%%
     AND prp.policy_type = '%%POLICY_TYPE%%'
     ORDER BY ID_PARENT_CAP_INSTANCE ASC
    	