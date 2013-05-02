
			SELECT 
			/* Query Tag: __GET_ROLES_ON_ACCOUNT__ */
     app.id_acc, app.id_policy AS id_acc_policy
     ,R.id_role
     , R.TX_NAME, R.TX_DESC
     FROM
     /* get policy ID for the account */
     T_PRINCIPAL_POLICY app
     /* get all the roles that sit on the account's policy */
     INNER JOIN T_POLICY_ROLE pr ON app.ID_POLICY = pr.ID_POLICY
     /* get definitions for these roles */
     INNER JOIN T_ROLE R ON PR.ID_ROLE = R.ID_ROLE
     WHERE app.id_ACC = %%ID_ACC%%
     AND app.policy_type = '%%POLICY_TYPE%%'
      