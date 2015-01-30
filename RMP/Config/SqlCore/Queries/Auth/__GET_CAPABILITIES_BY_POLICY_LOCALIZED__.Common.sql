
				SELECT DISTINCT
					/* Query Tag: __GET_CAPABILITIES_BY_POLICY__ */
					/* remove instance id because we wanted distinct records by type */
					/* id_cap_instance */
					t_capability_instance.id_cap_type, 
          type.tx_guid, 
          COALESCE(li.tx_name, type.tx_name) tx_name,        
          COALESCE(li.tx_desc, type.tx_desc) tx_desc,                        
          tx_progid, 
          tx_editor,
          csr_assignable, 
          subscriber_assignable, 
					(SELECT COUNT(*) FROM t_compositor WHERE id_composite = t_capability_instance.id_cap_type) num_atomic,
          umbrella_sensitive
				FROM t_capability_instance 
				INNER JOIN t_composite_capability_type type ON t_capability_instance.id_cap_type = type.id_cap_type 
        LEFT OUTER JOIN t_localized_items li ON (li.id_local_type = 2 /* where 2 - composite capability type */ AND type.id_cap_type = li.id_item AND li.id_lang_code = %%ID_LANG%%)
				WHERE id_parent_cap_instance IS NULL AND id_policy = %%ID_POLICY%%
    	