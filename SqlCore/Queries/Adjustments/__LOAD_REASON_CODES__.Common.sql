SELECT /* __LOAD_REASON_CODES__ */
       rc.id_prop ReasonCodeID,
       rc.tx_guid ReasonCodeGUID,
       base1.nm_name ReasonCodeName,
       COALESCE(desc2.tx_desc, base1.nm_desc) ReasonCodeDescription,	
       base1.n_display_name ReasonCodeDisplayNameID,       
	   COALESCE(desc1.tx_desc, base1.nm_display_name) ReasonCodeDisplayName,
       base1.n_desc ReasonCodeDisplayDescriptionID
FROM   t_reason_code rc
       INNER JOIN t_base_props base1
            ON  rc.id_prop = base1.id_prop
       LEFT JOIN t_description desc1
            ON  base1.n_display_name = desc1.id_desc AND desc1.id_lang_code = %%ID_LANG_CODE%%
	   LEFT JOIN t_description desc2
            ON  base1.n_desc = desc2.id_desc AND desc2.id_lang_code = %%ID_LANG_CODE%%
		
WHERE  1=1 
       %%PREDICATE%%
