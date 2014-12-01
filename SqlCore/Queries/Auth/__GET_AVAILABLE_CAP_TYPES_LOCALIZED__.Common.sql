
       SELECT 
       /* Query Tag: __GET_AVAILABLE_CAP_TYPES__ */
       type.id_cap_type, 
       type.tx_guid, 
       COALESCE(li.tx_name, type.tx_name) tx_name,        
       COALESCE(li.tx_desc, type.tx_desc) tx_desc,                        
       type.tx_progid, 
       type.tx_editor, 
       type.csr_assignable, 
       type.subscriber_assignable, 
       type.multiple_instances,
       (SELECT COUNT(*) FROM t_compositor WHERE id_composite = type.id_cap_type) num_atomic, 
       type.umbrella_sensitive
       
       FROM t_composite_capability_type type
       
       LEFT OUTER JOIN t_capability_instance ci ON ci.id_cap_type = type.id_cap_type 
       LEFT OUTER JOIN t_localized_items li ON type.id_cap_type = li.id_item AND li.id_lang_code = %%LANG_ID%% AND li.id_local_type = 2 --2 - composite capability type
       
       WHERE
       (
       /* this type has no instances */
       ci.id_cap_instance IS NULL) AND %%FLAG_CLAUSE%%
       union
       SELECT 
       /* Query Tag: __GET_AVAILABLE_CAP_TYPES__ */
       type.id_cap_type, 
       type.tx_guid, 
       COALESCE(li.tx_name, type.tx_name) tx_name,        
       COALESCE(li.tx_desc, type.tx_desc) tx_desc,                        
       type.tx_progid, 
       type.tx_editor, 
       type.csr_assignable, 
       type.subscriber_assignable, 
       type.multiple_instances,
       (SELECT COUNT(*) FROM t_compositor WHERE id_composite = type.id_cap_type) num_atomic, 
       type.umbrella_sensitive
       
       FROM t_composite_capability_type type
       
       INNER JOIN t_capability_instance ci ON ci.id_cap_type = type.id_cap_type 
       LEFT OUTER JOIN t_principal_policy pp ON ci.id_policy = pp.id_policy  
       LEFT OUTER JOIN t_localized_items li ON type.id_cap_type = li.id_item AND li.id_lang_code = %%LANG_ID%% AND li.id_local_type = 2 --2 - composite capability type
       
       WHERE
       /* this type already has instance */
       /* associated with principals of the other type */
       /* (role vs account) */
       (  pp.%%PRINCIPAL_COLUMN%% IS NULL AND
	        type.id_cap_type NOT IN
	        (SELECT t.id_cap_type FROM t_composite_capability_type t 
	         INNER JOIN
	         t_capability_instance i ON i.id_cap_type = t.id_cap_type
	         INNER JOIN 
	         t_principal_policy pp ON i.id_policy = pp.id_policy
	         WHERE pp.%%PRINCIPAL_COLUMN%% = %%PRINCIPAL_ID%%
	         and i.id_parent_cap_instance IS NULL)
	      ) AND %%FLAG_CLAUSE%%
	   union
       SELECT 
       /* Query Tag: __GET_AVAILABLE_CAP_TYPES__ */
       type.id_cap_type, 
       type.tx_guid, 
       COALESCE(li.tx_name, type.tx_name) tx_name,        
       COALESCE(li.tx_desc, type.tx_desc) tx_desc,                        
       type.tx_progid, 
       type.tx_editor, 
       type.csr_assignable, 
       type.subscriber_assignable, 
       type.multiple_instances,
       (SELECT COUNT(*) FROM t_compositor WHERE id_composite = type.id_cap_type) num_atomic, 
       type.umbrella_sensitive
       
       FROM t_composite_capability_type type
       
       INNER JOIN t_capability_instance ci ON ci.id_cap_type = type.id_cap_type 
       INNER JOIN t_principal_policy pp ON ci.id_policy = pp.id_policy  
       LEFT OUTER JOIN t_localized_items li ON type.id_cap_type = li.id_item AND li.id_lang_code = %%LANG_ID%% AND li.id_local_type = 2 --2 - composite capability type
       
       WHERE
       /* this type already has instance */
       /* associated with principals of the same type */
       /* but not with this one */
       (  pp.%%PRINCIPAL_COLUMN%% <> %%PRINCIPAL_ID%% AND
	        type.id_cap_type NOT IN
	        (SELECT t.id_cap_type FROM t_composite_capability_type t 
	         INNER JOIN
	         t_capability_instance i ON i.id_cap_type = t.id_cap_type
	         INNER JOIN 
	         t_principal_policy pp ON i.id_policy = pp.id_policy
	         WHERE pp.%%PRINCIPAL_COLUMN%% = %%PRINCIPAL_ID%%
	         and i.id_parent_cap_instance IS NULL)
	      ) AND %%FLAG_CLAUSE%%
       union
       SELECT 
       /* Query Tag: __GET_AVAILABLE_CAP_TYPES__ */
       type.id_cap_type, 
       type.tx_guid, 
       COALESCE(li.tx_name, type.tx_name) tx_name,        
       COALESCE(li.tx_desc, type.tx_desc) tx_desc,                        
       type.tx_progid, 
       type.tx_editor, 
       type.csr_assignable, 
       type.subscriber_assignable, 
       type.multiple_instances,
       (SELECT COUNT(*) FROM t_compositor WHERE id_composite = type.id_cap_type) num_atomic, 
       type.umbrella_sensitive
       
       FROM t_composite_capability_type type
       
       INNER JOIN t_capability_instance ci ON ci.id_cap_type = type.id_cap_type 
       INNER JOIN t_principal_policy pp ON ci.id_policy = pp.id_policy 
       LEFT OUTER JOIN t_localized_items li ON type.id_cap_type = li.id_item AND li.id_lang_code = %%LANG_ID%% AND li.id_local_type = 2     --2 - composite capability type   
       
       WHERE
       
       /* this type already has instance */
       /* associated with this principal, but it also doesn't */
       /* mind multiple instances */
       (pp.%%PRINCIPAL_COLUMN%% = %%PRINCIPAL_ID%% AND multiple_instances = N'Y')
       /* only composites */
       /* AND ci.id_parent_cap_instance IS NULL */
       AND %%FLAG_CLAUSE%%
    	