
				SELECT 
				/* Query Tag: __GET_CCTS__ */
				cct.id_cap_type, cct.tx_guid, cct.tx_name, cct.tx_desc, cct.tx_progid, cct.tx_editor, cct.csr_assignable,
		    cct.subscriber_assignable, cct.multiple_instances, cct.umbrella_sensitive
		    ,act.tx_progid atomic_tx_progid 
				,comp.tx_description CompositionDescription, comp.tx_param
				,act.id_cap_type atomic_id_cap_type, act.tx_guid, act.tx_name atomic_tx_name, act.tx_desc atomic_tx_desc
				,act.tx_editor atomic_tx_editor
		    FROM t_composite_capability_type cct
		    /* get all atomic mappings */
		    LEFT OUTER JOIN t_compositor comp ON comp.id_composite = cct.id_cap_type
		    /* get atomic type defs */
		    LEFT OUTER JOIN t_atomic_capability_type act ON comp.id_atomic = act.id_cap_type
    		ORDER BY cct.id_cap_type
    	