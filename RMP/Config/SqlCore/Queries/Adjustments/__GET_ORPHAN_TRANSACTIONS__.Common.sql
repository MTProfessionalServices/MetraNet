
		select
			am.nm_login UserNamePayer,			
			COALESCE(vajtemplatebp.nm_display_name, ajtemplatebp.nm_display_name) AS AdjustmentTemplateDisplayName,      
			COALESCE(vajinstancebp.nm_display_name, ajinstancebp.nm_display_name) AS AdjustmentInstanceDisplayName,
			rcbp.nm_name AS ReasonCodeName,      
			COALESCE(vrcbp.nm_desc, rcbp.nm_desc) AS ReasonCodeDescription,			
			COALESCE(vrcbp.nm_display_name, rcbp.nm_display_name) AS ReasonCodeDisplayName,
			ajt.am_currency AS Currency,
			ajt.* from 
			t_adjustment_transaction ajt
      INNER JOIN t_account_mapper am on ajt.id_acc_payer = am.id_acc
      INNER JOIN t_namespace ns on ns.nm_space = am.nm_space 
		AND ns.tx_typ_space IN ('system_mps')
		INNER JOIN t_enum_data ed on %%%UPPER%%%(ed.nm_enum_data) = %%%UPPER%%%('metratech.com/accountcreation/contacttype/bill-to')
	    /* resolve adjustment template or instance name */
      INNER JOIN t_base_props ajtemplatebp ON ajt.id_aj_template = ajtemplatebp.id_prop
      LEFT OUTER JOIN t_vw_base_props  vajtemplatebp ON ajtemplatebp.id_prop = vajtemplatebp.id_prop  AND vajtemplatebp.id_lang_code = %%ID_LANG%%
	  
      INNER JOIN t_base_props ajinstancebp ON ajt.id_aj_instance = ajinstancebp.id_prop
      LEFT OUTER JOIN t_vw_base_props  vajinstancebp ON ajinstancebp.id_prop = vajinstancebp.id_prop  AND vajinstancebp.id_lang_code = %%ID_LANG%%
      /* resolve adjustment reason code name */
      INNER JOIN t_base_props rcbp ON ajt.id_reason_code = rcbp.id_prop
      LEFT JOIN t_vw_base_props  vrcbp ON rcbp.id_prop = vrcbp.id_prop  AND vrcbp.id_lang_code = %%ID_LANG%%
	    %%PREDICATE%%
	    /* below predicates are redundant */
	    /* because c_status = 'O' means that id_sess will be NULL */
	    AND ajt.id_sess IS NULL
	    AND ajt.c_status = 'O'    
     
			%%FILTER%%
			