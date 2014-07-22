
          CREATE or replace force view VW_ADJUSTMENT_DETAILS as
          select distinct
          ajinfo.ID_SESS, ajinfo.TX_UID, ajinfo.ID_ACC, ajinfo.ID_PAYEE, ajinfo.ID_VIEW, 
          ajinfo.ID_USAGE_INTERVAL, ajinfo.ID_PARENT_SESS, ajinfo.ID_PROD, 
          ajinfo.ID_SVC, ajinfo.DT_SESSION, ajinfo.AMOUNT, ajinfo.AM_CURRENCY, 
          ajinfo.DT_CRT, ajinfo.TX_BATCH, ajinfo.TAX_FEDERAL, ajinfo.TAX_STATE, 
          ajinfo.TAX_COUNTY, ajinfo.TAX_LOCAL, ajinfo.TAX_OTHER, ajinfo.ID_PI_INSTANCE, 
          ajinfo.ID_PI_TEMPLATE, ajinfo.ID_SE, ajinfo.COMPOUNDPREBILLAdjAmt, 
          ajinfo.CompoundPrebillAdjedAmt, ajinfo.AtomicPrebillAdjAmt, ajinfo.AtomicPrebillAdjedAmt, 
          ajinfo.PENDINGPREBILLAdjAmt, ajinfo.COMPOUNDPREBILLFedTaxAdjAmt, 
          ajinfo.COMPOUNDPREBILLSTATETAXADJAMT, ajinfo.COMPOUNDPREbillCntyTAXADJAMT, 
          ajinfo.COMPOUNDPREBILLLOCALTAXADJAMT, ajinfo.COMPOUNDPREBILLOTHERTAXADJAMT, 
          ajinfo.COMPOUNDPREBILLTOTALTAXADJAMT, ajinfo.AtomicPrebillFedTaxAdjAmt, 
          ajinfo.ATOMICPREBILLSTATETAXADJAMT, ajinfo.ATOMICPREbillCntyTAXADJAMT, 
          ajinfo.ATOMICPREBILLLOCALTAXADJAMT, ajinfo.ATOMICPREBILLOTHERTAXADJAMT, 
          ajinfo.ATOMICPREBILLTOTALTAXADJAMT, ajinfo.COMPOUNDPOSTBILLAdjAmt, ajinfo.CompoundPostbillAdjedAmt, 
          ajinfo.AtomicPostbillAdjAmt, ajinfo.AtomicPostbillAdjedAmt, ajinfo.PENDINGPOSTBILLAdjAmt, 
          ajinfo.COMPOUNDPOSTBILLFedTaxAdjAmt, ajinfo.COMPOUNDPOSTBILLSTATETAXADJAMT, 
          ajinfo.CompoundPostbillCntyTaxAdjAmt, ajinfo.COMPOUNDPOSTBILLLOCALTAXADJAMT, 
          ajinfo.COMPOUNDPOSTBILLOTHERTAXADJAMT, ajinfo.COMPOUNDPOSTBILLTOTALTAXADJAMT, 
          ajinfo.ATOMICPOSTBILLFedTaxAdjAmt, ajinfo.ATOMICPOSTBILLSTATETAXADJAMT, 
          ajinfo.ATOMICPOSTbillCntyTAXADJAMT, ajinfo.ATOMICPOSTBILLLOCALTAXADJAMT, 
          ajinfo.ATOMICPOSTBILLOTHERTAXADJAMT, ajinfo.ATOMICPOSTBILLTOTALTAXADJAMT, 
          ajinfo.PREBILLADJUSTMENTID, ajinfo.POSTBILLADJUSTMENTID, ajinfo.PREBILLADJUSTMENTTEMPLATEID, 
          ajinfo.POSTBILLADJUSTMENTTEMPLATEID, ajinfo.PREBILLADJUSTMENTINSTANCEID, 
          ajinfo.POSTBILLADJUSTMENTINSTANCEID, ajinfo.PREBILLADJUSTMENTREASONCODEID, 
          ajinfo.POSTBILLADJUSTMENTREASONCODEID, ajinfo.PREBILLADJUSTMENTDESCRIPTION, 
          ajinfo.POSTBILLADJUSTMENTDESCRIPTION, ajinfo.PREBILLADJDEFAULTDESC, 
          ajinfo.POSTBILLADJDEFAULTDESC, ajinfo.ADJUSTMENTSTATUS, ajinfo.ISADJUSTED, 
          ajinfo.ISPREBILLADJUSTED, ajinfo.ISPOSTBILLADJUSTED, ajinfo.ISPREBILL, ajinfo.CANADJUST, 
          ajinfo.CANREBILL, ajinfo.CANMANAGEPREBILLADJUSTMENT, ajinfo.CANMANAGEPOSTBILLADJUSTMENT, 
          ajinfo.CANMANAGEADJUSTMENTS, ajinfo.ISINTERVALSOFTCLOSED, ajinfo.NUMPREBILLADJUSTEDCHILDREN, 
          ajinfo.NUMPOSTBILLADJUSTEDCHILDREN,
          ajt.id_adj_trx,
          ajt.id_reason_code,
          ajt.id_acc_creator,
          ajt.id_acc_payer,
          ajt.c_status,
          ajt.dt_crt AS AdjustmentCreationDate,
          ajt.dt_modified,
          ajt.id_aj_type,
          ajt.id_aj_template AS id_aj_template,
          ajt.id_aj_instance AS id_aj_instance,
          ajt.id_usage_interval AS AdjustmentUsageInterval,
          ajt.tx_desc,
          ajt.tx_default_desc,
          ajt.n_adjustmenttype,
          nvl(ajtemplatedesc.tx_desc,'') as AdjustmentTemplateDisplayName,
          nvl(ajinstancedesc.tx_desc,'') as AdjustmentInstanceDisplayName,
          CASE WHEN (rcbp.nm_name IS NULL) THEN translate('' using nchar_cs) ELSE rcbp.nm_name END  AS ReasonCodeName,
          CASE WHEN (rcbp.nm_desc IS NULL) THEN translate('' using nchar_cs) ELSE rcbp.nm_desc END  AS ReasonCodeDescription,
          CASE WHEN (rcdesc.tx_desc IS NULL) THEN translate('' using nchar_cs) ELSE rcdesc.tx_desc END  AS ReasonCodeDisplayName,
          nvl(ajinstancedesc.id_lang_code,ajtemplatedesc.id_lang_code) as LanguageCode,
          ajinfo.AtomicPrebillAdjAmt AS PrebillAdjAmt,
          ajinfo.AtomicPostbillAdjAmt AS PostbillAdjAmt
          FROM  t_description rcdesc INNER JOIN
                  t_base_props rcbp ON rcdesc.id_desc = rcbp.n_display_name FULL OUTER JOIN
                  t_adjustment_transaction ajt INNER JOIN
                  VW_AJ_INFO ajinfo ON ajt.id_sess = ajinfo.id_sess INNER JOIN
                  /*resolve adjustment template or instance name                      */
                  t_base_props ajtemplatebp ON ajt.id_aj_template = ajtemplatebp.id_prop LEFT OUTER JOIN
                  t_description ajtemplatedesc ON ajtemplatebp.n_display_name = ajtemplatedesc.id_desc LEFT OUTER JOIN
                  t_base_props ajinstancebp ON ajt.id_aj_instance = ajinstancebp.id_prop LEFT OUTER JOIN
                  t_description ajinstancedesc ON ajinstancebp.n_display_name = ajinstancedesc.id_desc LEFT OUTER JOIN
                  t_description des2 ON des2.id_lang_code = ajtemplatedesc.id_lang_code AND des2.id_desc = ajinstancebp.n_display_name LEFT OUTER JOIN
                  t_description des3 ON des3.id_lang_code = ajinstancedesc.id_lang_code AND des3.id_desc = ajtemplatebp.n_display_name ON 
                  /*resolve adjustment reason code name                  */
                  rcdesc.id_lang_code = nvl(ajinstancedesc.id_lang_code, ajtemplatedesc.id_lang_code) AND rcbp.id_prop = ajt.id_reason_code
          WHERE ajt.c_status = 'A'
          and
          ( ajtemplatedesc.id_lang_code=ajinstancedesc.id_lang_code
          or des2.id_lang_code is null
          or des3.id_lang_code is null
          )
        