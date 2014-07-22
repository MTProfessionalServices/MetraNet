
          CREATE view VW_ADJUSTMENT_DETAILS as
			select distinct
                ajt.id_adj_trx,
                ajt.id_reason_code,
                ajt.id_acc_creator,
                ajt.id_acc_payer,
                ajt.c_status,
                ajt.dt_crt AS AdjustmentCreationDate,
                ajt.dt_modified,
                ajt.id_aj_type,
                ajt.id_aj_template 'id_aj_template',
				ajt.id_aj_instance 'id_aj_instance',
				ajt.id_usage_interval AS AdjustmentUsageInterval,
				ajt.tx_desc,
				ajt.tx_default_desc,
				ajt.n_adjustmenttype,
				isnull(ajtemplatedesc.tx_desc,'') as 'AdjustmentTemplateDisplayName',
				isnull(ajinstancedesc.tx_desc,'') as 'AdjustmentInstanceDisplayName',
				CASE WHEN (rcbp.nm_name IS NULL) THEN '' ELSE rcbp.nm_name END  AS ReasonCodeName,
				CASE WHEN (rcbp.nm_desc IS NULL) THEN '' ELSE rcbp.nm_desc END  AS ReasonCodeDescription,
				CASE WHEN (rcdesc.tx_desc IS NULL) THEN '' ELSE rcdesc.tx_desc END  AS ReasonCodeDisplayName,
				isnull(ajinstancedesc.id_lang_code,ajtemplatedesc.id_lang_code) as 'LanguageCode',
				ajinfo.AtomicPrebillAdjAmt AS PrebillAdjAmt,
				ajinfo.AtomicPostbillAdjAmt AS PostbillAdjAmt,
				ajinfo.*
            FROM  t_description AS rcdesc INNER JOIN
                  t_base_props AS rcbp ON rcdesc.id_desc = rcbp.n_display_name FULL OUTER JOIN
                  t_adjustment_transaction AS ajt INNER JOIN
                  VW_AJ_INFO AS ajinfo ON ajt.id_sess = ajinfo.id_sess INNER JOIN
                  --resolve adjustment template or instance name                      
                  t_base_props AS ajtemplatebp ON ajt.id_aj_template = ajtemplatebp.id_prop LEFT OUTER JOIN
                  t_description AS ajtemplatedesc ON ajtemplatebp.n_display_name = ajtemplatedesc.id_desc LEFT OUTER JOIN
                  t_base_props AS ajinstancebp ON ajt.id_aj_instance = ajinstancebp.id_prop LEFT OUTER JOIN
                  t_description AS ajinstancedesc ON ajinstancebp.n_display_name = ajinstancedesc.id_desc LEFT OUTER JOIN
                  t_description AS des2 ON des2.id_lang_code = ajtemplatedesc.id_lang_code AND des2.id_desc = ajinstancebp.n_display_name LEFT OUTER JOIN
                  t_description AS des3 ON des3.id_lang_code = ajinstancedesc.id_lang_code AND des3.id_desc = ajtemplatebp.n_display_name ON 
                  --resolve adjustment reason code name                  
                  rcdesc.id_lang_code = ISNULL(ajinstancedesc.id_lang_code, ajtemplatedesc.id_lang_code) AND rcbp.id_prop = ajt.id_reason_code
            WHERE ajt.c_status = 'A'
				and
				( ajtemplatedesc.id_lang_code=ajinstancedesc.id_lang_code
				or des2.id_lang_code is null
				or des3.id_lang_code is null
				)
				