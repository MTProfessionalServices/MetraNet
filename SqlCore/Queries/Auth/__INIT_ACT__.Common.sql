
				SELECT 
				/* Query Tag: __INIT_ACT__ */
				act.id_cap_type, act.tx_guid, act.tx_name, act.tx_desc, act.tx_progid, act.tx_editor
		    FROM t_atomic_capability_type act
		    WHERE act.id_cap_type= %%ACT_ID%%
    	