
			SELECT 
			/* Query Tag: __GET_POLICY__ */
			id_policy
     	FROM
     	T_PRINCIPAL_POLICY prp
     	WHERE prp.%%PRINCIPAL_COLUMN%% = %%PRINCIPAL_ID%% 
     	AND %%%UPPER%%%(prp.policy_type) = %%%UPPER%%%(N'%%POLICY_TYPE%%')
     