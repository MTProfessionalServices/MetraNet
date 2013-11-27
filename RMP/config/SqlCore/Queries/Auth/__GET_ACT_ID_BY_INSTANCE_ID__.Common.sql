
				SELECT 
				/* Query Tag: __GET_ACT_ID_BY_INSTANCE_ID__ */
				act.id_cap_type FROM t_atomic_capability_type act, t_capability_instance ins
    		WHERE ins.id_cap_type=act.id_cap_type AND
    		ins.id_cap_instance = %%INSTANCE_ID%%
    	