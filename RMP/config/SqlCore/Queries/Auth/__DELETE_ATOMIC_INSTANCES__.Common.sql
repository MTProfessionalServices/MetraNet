
			DELETE 
			/* Query Tag: __DELETE_ATOMIC_INSTANCES__ */
			FROM t_capability_instance WHERE id_parent_cap_instance = %%PARENT_ID%% AND
      id_policy = %%POLICY_ID%% And id_cap_type = %%TYPE_ID%%
    	