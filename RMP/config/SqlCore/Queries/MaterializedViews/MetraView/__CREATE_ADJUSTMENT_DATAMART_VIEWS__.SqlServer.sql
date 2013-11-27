
	      begin
		exec ('CREATE view VW_ADJUSTMENT_SUMMARY_DATAMART as
			select
          ajtrx.id_acc_payer id_acc,
          ajtrx.id_usage_interval,
          ajtrx.am_currency,
          ajui.dt_start,
          ajui.dt_end,
        --add info about adjustments
        SUM (CASE WHEN ajtrx.n_adjustmenttype=0  THEN ajtrx.AdjustmentAmount ELSE 0 END)  AS PrebillAdjAmt
        ,SUM (CASE WHEN ajtrx.n_adjustmenttype=0  THEN aj_tax_federal+aj_tax_state+aj_tax_county+aj_tax_local+aj_tax_other ELSE 0 END)  AS PrebillTaxAdjAmt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=0  THEN aj_tax_federal ELSE 0 END)  AS PrebillFederalTaxAdjustAmt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=0  THEN aj_tax_state ELSE 0 END)  AS PrebillStateTaxAdjAmt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=0  THEN aj_tax_county ELSE 0 END)  AS PrebillCntyTaxAdjAmt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=0  THEN aj_tax_local ELSE 0 END)  AS PrebillLocalTaxAdjAmnt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=0  THEN aj_tax_other ELSE 0 END)  AS PrebillOtherTaxAdjAmnt
       ,SUM (CASE WHEN ajtrx.n_adjustmenttype=1  THEN ajtrx.AdjustmentAmount ELSE 0 END)  AS PostbillAdjAmt
        ,SUM (CASE WHEN ajtrx.n_adjustmenttype=1  THEN aj_tax_federal+aj_tax_state+aj_tax_county+aj_tax_local+aj_tax_other ELSE 0 END)  AS PostbillTaxAdjAmt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=1  THEN aj_tax_federal ELSE 0 END)  AS PostbillFedTaxAdjAmt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=1  THEN aj_tax_state ELSE 0 END)  AS PostbillStateTaxAdjAmt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=1  THEN aj_tax_county ELSE 0 END)  AS PostbillCntyTaxAdjAmt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=1  THEN aj_tax_local ELSE 0 END)  AS PostbillLocalTaxAdjAmt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=1  THEN aj_tax_other ELSE 0 END)  AS PostbillOtherTaxAdjAmt
        ,SUM (CASE WHEN ajtrx.n_adjustmenttype=1  THEN 1 ELSE 0 END)  AS NumPostbillAdjustments
        ,SUM (CASE WHEN ajtrx.n_adjustmenttype=0  THEN 1 ELSE 0 END)  AS NumPrebillAdjustments
        FROM t_adjustment_transaction ajtrx
        INNER JOIN t_usage_interval ajui on ajui.id_interval = ajtrx.id_usage_interval
        WHERE  ajtrx.c_status = ''A''
				and (id_sess is not null or archive_sess is not null)
        and isnull(ajtrx.id_sess,ajtrx.archive_sess) <=(select id_sess from t_mv_max_sess)        
        GROUP BY
          ajtrx.id_acc_payer,
          ajtrx.id_usage_interval,
          ajtrx.am_currency,
          ajtrx.c_status,
          ajui.dt_start,
          ajui.dt_end')
          
        exec ('CREATE view VW_ADJUSTMENT_DETAILS_DATAMART as
			select distinct
				ajt.id_adj_trx,
				ajt.id_reason_code,
				ajt.id_acc_creator,
				ajt.id_acc_payer,
				ajt.c_status c_status1,
				ajt.dt_crt AS AdjustmentCreationDate,
				ajt.dt_modified,
				ajt.id_aj_type,
				ajt.id_aj_template ''id_aj_template'',
				ajt.id_aj_instance ''id_aj_instance'',
				ajt.id_usage_interval AS AdjustmentUsageInterval,
				ajt.tx_desc,
				ajt.tx_default_desc,
				ajt.n_adjustmenttype,
				isnull(ajtemplatedesc.tx_desc,'''') as ''AdjustmentTemplateDisplayName'',
				isnull(ajinstancedesc.tx_desc,'''') as ''AdjustmentInstanceDisplayName'',
				CASE WHEN (rcbp.nm_name IS NULL) THEN '''' ELSE rcbp.nm_name END  AS ReasonCodeName,
				CASE WHEN (rcbp.nm_desc IS NULL) THEN '''' ELSE rcbp.nm_desc END  AS ReasonCodeDescription,
				CASE WHEN (rcdesc.tx_desc IS NULL) THEN '''' ELSE rcdesc.tx_desc END  AS ReasonCodeDisplayName,
				isnull(ajinstancedesc.id_lang_code,ajtemplatedesc.id_lang_code) as ''LanguageCode'',
				ajinfo.AtomicPrebillAdjAmt AS PrebillAdjAmt,
				ajinfo.AtomicPostbillAdjAmt AS PostbillAdjAmt,
				ajinfo.*
				FROM t_adjustment_transaction ajt
				INNER JOIN t_mv_adjustments_usagedetail ajinfo ON ajt.id_sess = ajinfo.id_sess
				--resolve adjustment template or instance name
				INNER JOIN t_base_props ajtemplatebp ON ajt.id_aj_template = ajtemplatebp.id_prop
				left outer JOIN t_description  ajtemplatedesc ON ajtemplatebp.n_display_name = ajtemplatedesc.id_desc
				left outer JOIN t_base_props ajinstancebp ON ajt.id_aj_instance = ajinstancebp.id_prop
				LEFT OUTER JOIN t_description  ajinstancedesc ON ajinstancebp.n_display_name = ajinstancedesc.id_desc
				left outer join t_description des2 on des2.id_lang_code = ajtemplatedesc.id_lang_code and des2.id_desc =  ajinstancebp.n_display_name
				left outer join t_description des3 on des3.id_lang_code = ajinstancedesc.id_lang_code and des3.id_desc =  ajtemplatebp.n_display_name   
				--resolve adjustment reason code name
				INNER JOIN t_base_props rcbp ON ajt.id_reason_code = rcbp.id_prop
				INNER JOIN t_description  rcdesc ON rcbp.n_display_name = rcdesc.id_desc
				and
				rcdesc.id_lang_code = isnull(ajinstancedesc.id_lang_code,ajtemplatedesc.id_lang_code)
				WHERE ajt.c_status = ''A''
				and
				( ajtemplatedesc.id_lang_code=ajinstancedesc.id_lang_code
				or des2.id_lang_code is null
				or des3.id_lang_code is null
				)')
			end
		