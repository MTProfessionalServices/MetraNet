
				SELECT DISTINCT
					/* Query Tag: __GET_CAPABILITIES_BY_POLICY__ */
					/* remove instance id because we wanted distinct records by type */
					/* id_cap_instance */
					t_capability_instance.id_cap_type, t_composite_capability_type.tx_guid, tx_name, tx_desc, tx_progid, tx_editor
						,csr_assignable, subscriber_assignable, 
					(SELECT COUNT(*) FROM t_compositor 
					WHERE id_composite = t_capability_instance.id_cap_type) num_atomic
					,umbrella_sensitive
				FROM t_capability_instance 
				INNER JOIN t_composite_capability_type ON t_capability_instance.id_cap_type = t_composite_capability_type.id_cap_type 
				WHERE id_parent_cap_instance IS NULL AND id_policy = %%ID_POLICY%%
    	