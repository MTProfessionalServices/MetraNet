
				insert into t_policy_role(id_policy,	id_role)
        select policy.id_policy, %%ID_ROLE%% from t_principal_policy policy %%%READCOMMITTED%%%
        inner	join %%TEMPTABLE%% temptable %%%READCOMMITTED%%%
        on policy.id_acc = temptable.id_acc
        left outer join	t_policy_role	existing %%%READCOMMITTED%%% on	existing.id_policy = policy.id_policy	
        AND	existing.id_role = %%ID_ROLE%%
        where	
        ((temptable.acc_type <> 'SYSTEMACCOUNT' AND	%%SUB_ASSIGNABLE%%=1)
        OR
        (temptable.acc_type =	'SYSTEMACCOUNT' AND	%%CSR_ASSIGNABLE%%=1))
        
        /* protect ourselves from	generating FK	violation	on t_policy_role.id_policy.	This can only	happen
        if t_principal_policy record	was	not	yet	generated	for	this account.
        However,	this should	NEVER	be the case */
        
        AND	
        policy.id_policy IS	NOT	NULL
        /* Only take a record for active policy */
        AND policy.policy_type = 'A'
          
        /* only	insert if	this account doesn't already have	this role. This	may	happen
         during	account	updates */
        AND	existing.id_policy IS	NULL
			  