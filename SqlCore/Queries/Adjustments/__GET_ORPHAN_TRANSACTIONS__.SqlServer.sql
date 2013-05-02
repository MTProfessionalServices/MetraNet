
			select
			am.nm_login UserNamePayer, 
			CASE WHEN (ajtemplatedesc.tx_desc IS NULL) THEN '' ELSE ajtemplatedesc.tx_desc END  AS AdjustmentTemplateDisplayName,
      CASE WHEN (ajinstancedesc.tx_desc IS NULL) THEN '' ELSE ajinstancedesc.tx_desc END  AS AdjustmentInstanceDisplayName,
      CASE WHEN (rcbp.nm_name IS NULL) THEN '' ELSE rcbp.nm_name END  AS ReasonCodeName,
      CASE WHEN (rcbp.nm_desc IS NULL) THEN '' ELSE rcbp.nm_desc END  AS ReasonCodeDescription,
      CASE WHEN (rcdesc.tx_desc IS NULL) THEN '' ELSE rcdesc.tx_desc END  AS ReasonCodeDisplayName,
      ajt.am_currency AS Currency,
			* from 
			t_adjustment_transaction ajt
      inner join dbo.t_account_mapper am on ajt.id_acc_payer = am.id_acc
      INNER JOIN dbo.t_namespace ns on ns.nm_space = am.nm_space 
		AND ns.tx_typ_space IN ('system_mps')
		INNER JOIN dbo.t_enum_data ed on %%%UPPER%%%(ed.nm_enum_data) = %%%UPPER%%%('metratech.com/accountcreation/contacttype/bill-to')
	    /* resolve adjustment template or instance name */
      INNER JOIN t_base_props ajtemplatebp ON ajt.id_aj_template = ajtemplatebp.id_prop
      INNER JOIN t_description  ajtemplatedesc ON ajtemplatebp.n_display_name = ajtemplatedesc.id_desc
      LEFT OUTER JOIN t_base_props ajinstancebp ON ajt.id_aj_instance = ajinstancebp.id_prop
      LEFT OUTER JOIN t_description  ajinstancedesc ON ajinstancebp.n_display_name = ajinstancedesc.id_desc
      /* resolve adjustment reason code name */
      INNER JOIN t_base_props rcbp ON ajt.id_reason_code = rcbp.id_prop
      INNER JOIN t_description  rcdesc ON rcbp.n_display_name = rcdesc.id_desc
	    %%PREDICATE%%
	    /* below predicates are redundant */
	    /* because c_status = 'O' means that id_sess will be NULL */
	    AND ajt.id_sess IS NULL
	    AND ajt.c_status = 'O'
	    AND rcdesc.id_lang_code = ajtemplatedesc.id_lang_code
      AND (ajinstancedesc.id_lang_code IS NULL 
      OR ( ajtemplatedesc.id_lang_code = ajinstancedesc.id_lang_code))
      AND rcdesc.id_lang_code = %%ID_LANG%%
			%%FILTER%%
			