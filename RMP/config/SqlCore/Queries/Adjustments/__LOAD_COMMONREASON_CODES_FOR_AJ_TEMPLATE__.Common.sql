
     select 
     /* __LOAD_COMMONREASON_CODES_FOR_AJ_TEMPLATE__ */
      rc.id_prop ReasonCodeID,	rc.tx_guid ReasonCodeGUID,
      base1.nm_name	ReasonCodeName,	base1.nm_desc	ReasonCodeDescription, base1.n_display_name ReasonCodeDisplayNameID, desc1.tx_desc ReasonCodeDisplayName
      FROM T_AJ_TEMPLATE_REASON_CODE_MAP map
      INNER JOIN t_reason_code rc ON map.id_reason_code = rc.id_prop
      INNER JOIN	t_base_props base1 ON	rc.id_prop	=	base1.id_prop
      INNER JOIN	t_description	desc1	ON base1.n_display_name	=	desc1.id_desc
      WHERE desc1.id_lang_code = %%ID_LANG_CODE%% 
      AND map.id_adjustment in (%%ID_AJLIST%%)
	group by rc.id_prop ,rc.tx_guid ,base1.nm_name,	base1.nm_desc, base1.n_display_name, desc1.tx_desc 
	/* having count(rc.id_prop) >= %%ID_COUNT%% */
	having count(rc.id_prop) = 1

      
			