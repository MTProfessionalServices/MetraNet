
			SELECT 
		  /* Query Tag: __GET_POST_BILL_ADJUSTMENT_DETAIL_DATAMART__ */
			CASE ajt.n_adjustmenttype WHEN 0 THEN 'Prebill' ELSE 'Postbill' END AdjustmentType,	
        	(CASE WHEN (ajt.id_adj_trx IS NOT NULL AND ajt.c_status = 'A')	
	        THEN ajt.AdjustmentAmount ELSE 0 END) as AdjustmentAmount, 
			ajt.id_reason_code ReasonCode,
			{fn IFNULL(ajtemplatedesc.tx_desc,'')} as AdjustmentTemplateDisplayName,
			{fn IFNULL(ajinstancedesc.tx_desc,'')} as AdjustmentInstanceDisplayName,
			{fn IFNULL(rcbp.nm_name,'')} as ReasonCodeName,
			{fn IFNULL(rcbp.nm_desc,'')} as ReasonCodeDescription,
			{fn IFNULL(rcdesc.tx_desc,'')} as ReasonCodeDisplayName,
			{fn IFNULL(ajt.tx_desc, '')} Description
	  		FROM t_adjustment_transaction ajt
		    INNER JOIN t_base_props ajtemplatebp ON ajt.id_aj_template = ajtemplatebp.id_prop
          	INNER JOIN t_description  ajtemplatedesc ON ajtemplatebp.n_display_name = ajtemplatedesc.id_desc
          	LEFT OUTER JOIN t_base_props ajinstancebp ON ajt.id_aj_instance = ajinstancebp.id_prop
          	LEFT OUTER JOIN t_description  ajinstancedesc ON ajinstancebp.n_display_name = ajinstancedesc.id_desc
          	/*resolve adjustment reason code name */
          	INNER JOIN t_base_props rcbp ON ajt.id_reason_code = rcbp.id_prop
          	INNER JOIN t_description  rcdesc ON rcbp.n_display_name = rcdesc.id_desc
          	WHERE ajt.c_status = 'A'
          	AND 
		    (
          	ajinstancedesc.id_lang_code IS NULL OR  ((ajinstancedesc.id_lang_code = ajtemplatedesc.id_lang_code)
          	AND (ajinstancedesc.id_lang_code = rcdesc.id_lang_code))
          	)
			and
			ajt.id_acc_payer = %%ID_ACC%%
			AND ajt.id_usage_interval =  %%ID_INTERVAL%%
			/* realated to CR 9739: only return postbill adjustments
			 IsPostbillADjusted flag doesn't really do it */
			AND n_adjustmenttype = 1
			/*TODO: pass lang code into query */
			AND ajtemplatedesc.id_lang_code = 840
			 