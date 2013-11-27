
			DELETE 
			/* Query Tag: __DELETE_COMPOSITE_INSTANCES__ */
			FROM t_capability_instance WHERE id_parent_cap_instance IS NULL AND
      id_policy = %%POLICY_ID%% And id_cap_type = %%TYPE_ID%%
    	