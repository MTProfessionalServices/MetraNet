
				SELECT 
				/* Query Tag: __GET_COMPOSITE_CAP_TYPES__ */
				type.id_cap_type, 
        type.tx_guid,
        COALESCE(li.tx_name, type.tx_name) tx_name,        
        COALESCE(li.tx_desc, type.tx_desc) tx_desc,                        
        type.tx_progid, 
        type.tx_editor, 
        type.csr_assignable, 
        type.subscriber_assignable, 
        type.multiple_instances
				,(SELECT COUNT(*) FROM t_compositor WHERE id_composite = type.id_cap_type) num_atomic
				, type.umbrella_sensitive
				FROM t_composite_capability_type type 
        LEFT OUTER JOIN t_localized_items li ON (li.id_local_type = 2 /* where 2 - composite capability type */ AND type.id_cap_type = li.id_item AND li.id_lang_code = %%LANG_ID%%) 	