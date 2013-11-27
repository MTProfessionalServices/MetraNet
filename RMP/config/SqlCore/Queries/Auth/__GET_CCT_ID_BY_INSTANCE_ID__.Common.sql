
				SELECT 
				/* Query Tag: __GET_CCT_ID_BY_INSTANCE_ID__ */
				cct.id_cap_type FROM t_composite_capability_type cct, t_capability_instance ins
    		WHERE ins.id_cap_type=cct.id_cap_type AND
    		ins.id_cap_instance = %%INSTANCE_ID%%
    	