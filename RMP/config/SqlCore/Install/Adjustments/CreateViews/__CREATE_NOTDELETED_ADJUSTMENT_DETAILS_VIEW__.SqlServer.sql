
          CREATE view VW_NOTDELETED_ADJ_DETAILS as
           select
          ajt.id_adj_trx,
          ajt.id_reason_code,
          ajt.id_acc_creator,
          ajt.id_acc_payer,
          ajt.c_status,
          ajt.dt_crt AS AdjustmentCreationDate,
          ajt.dt_modified,
          ajt.id_aj_type,
          ajt.id_aj_template,
          ajt.id_aj_instance,
          ajt.id_usage_interval AS AdjustmentUsageInterval,
          ajt.tx_desc,
          ajt.tx_default_desc,
          ajt.n_adjustmenttype,
          CASE WHEN (ajtemplatedesc.tx_desc IS NULL) THEN '' ELSE ajtemplatedesc.tx_desc END  AS AdjustmentTemplateDisplayName,
          CASE WHEN (ajinstancedesc.tx_desc IS NULL) THEN '' ELSE ajinstancedesc.tx_desc END  AS AdjustmentInstanceDisplayName,
          CASE WHEN (rcbp.nm_name IS NULL) THEN '' ELSE rcbp.nm_name END  AS ReasonCodeName,
          CASE WHEN (rcbp.nm_desc IS NULL) THEN '' ELSE rcbp.nm_desc END  AS ReasonCodeDescription,
          CASE WHEN (rcdesc.tx_desc IS NULL) THEN '' ELSE rcdesc.tx_desc END  AS ReasonCodeDisplayName,
          ajtemplatedesc.id_lang_code AS LanguageCode,
          ajinfo.AtomicPrebillAdjAmt AS PrebillAdjAmt,
          ajinfo.AtomicPostbillAdjAmt AS PostbillAdjAmt,
          ajinfo.*
          FROM t_adjustment_transaction ajt
          INNER JOIN VW_AJ_INFO ajinfo ON ajt.id_sess = ajinfo.id_sess
          --resolve adjustment template or instance name
          INNER JOIN t_base_props ajtemplatebp ON ajt.id_aj_template = ajtemplatebp.id_prop
          INNER JOIN t_description  ajtemplatedesc ON ajtemplatebp.n_display_name = ajtemplatedesc.id_desc
          LEFT OUTER JOIN t_base_props ajinstancebp ON ajt.id_aj_instance = ajinstancebp.id_prop
          LEFT OUTER JOIN t_description  ajinstancedesc ON ajinstancebp.n_display_name = ajinstancedesc.id_desc
          --resolve adjustment reason code name
          INNER JOIN t_base_props rcbp ON ajt.id_reason_code = rcbp.id_prop
          INNER JOIN t_description  rcdesc ON rcbp.n_display_name = rcdesc.id_desc
          and rcdesc.id_lang_code = isnull(ajinstancedesc.id_lang_code,ajtemplatedesc.id_lang_code)
          WHERE ajt.c_status IN ('A', 'P')
          AND 
          (
          ajinstancedesc.id_lang_code IS NULL OR  (ajinstancedesc.id_lang_code = ajtemplatedesc.id_lang_code)
          )
				