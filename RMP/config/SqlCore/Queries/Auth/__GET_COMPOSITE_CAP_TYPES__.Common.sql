
				SELECT 
				/* Query Tag: __GET_COMPOSITE_CAP_TYPES__ */
				type.id_cap_type, type.tx_guid, type.tx_name, type.tx_desc, type.tx_progid, type.tx_editor, type.csr_assignable, type.subscriber_assignable, type.multiple_instances
				,(SELECT COUNT(*) FROM t_compositor WHERE id_composite = type.id_cap_type) num_atomic
				, type.umbrella_sensitive
				FROM t_composite_capability_type type
    	