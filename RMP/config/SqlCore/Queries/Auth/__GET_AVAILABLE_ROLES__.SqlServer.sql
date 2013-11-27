
    		SELECT DISTINCT
        /* Query Tag: __GET_AVAILABLE_ROLES__ */
        r.id_role, tx_guid, r.tx_name, r.tx_desc
        ,r.csr_assignable, r.subscriber_assignable
        FROM t_role r
        LEFT OUTER JOIN t_policy_role pr ON r.id_role = pr.id_role
        WHERE 
          r.id_role NOT IN 
          ( SELECT ipr.id_role FROM t_policy_role ipr
            INNER JOIN t_principal_policy ipp ON ipr.id_policy = ipp.id_policy
            WHERE ipp.id_acc = %%ID%% and ipp.policy_type = N'%%POLICY_TYPE%%'
           )
        AND r.%%FLAG_COLUMN%% = N'Y'
    	