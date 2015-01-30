
				SELECT 
				/* Query Tag: __INIT_CCT_LOCALIZED__ */
        DISTINCT 
				cct.id_cap_type, 
        cct.tx_guid  tx_guid,         
        COALESCE(li.tx_name, cct.tx_name) tx_name,        
        COALESCE(li.tx_desc, cct.tx_desc) tx_desc,                
        cct.tx_progid, 
        cct.tx_editor, 
        cct.csr_assignable,
		    cct.subscriber_assignable, 
        cct.multiple_instances,
        cct.umbrella_sensitive,
		    act.tx_progid atomic_tx_progid, 
				COALESCE(li2.tx_desc, comp.tx_description) CompositionDescription, 
        comp.tx_param,
				act.id_cap_type atomic_id_cap_type, 
        act.tx_guid atomic_tx_guid, 
        act.tx_name atomic_tx_name, 
        act.tx_desc atomic_tx_desc,
				act.tx_editor atomic_tx_editor
		    FROM t_composite_capability_type cct
		    /* get all atomic mappings */
		    LEFT OUTER JOIN t_compositor comp ON comp.id_composite = cct.id_cap_type
		    /* get atomic type defs */
		    LEFT OUTER JOIN t_atomic_capability_type act ON comp.id_atomic = act.id_cap_type
        /* get localizations */
        LEFT OUTER JOIN t_localized_items li ON (li.id_local_type = 2 /* where 2 - composite capability type */ AND cct.id_cap_type = li.id_item AND li.id_lang_code = %%LANG_ID%%)
        LEFT OUTER JOIN t_localized_items li2 ON (li2.id_local_type = 3 /* where 3 - atomic capability type */ AND comp.id_atomic = li2.id_item_second_key AND cct.id_cap_type = li2.id_item AND li2.id_lang_code = %%LANG_ID%%)         
    		WHERE cct.id_cap_type= %%CCT_ID%%
    	