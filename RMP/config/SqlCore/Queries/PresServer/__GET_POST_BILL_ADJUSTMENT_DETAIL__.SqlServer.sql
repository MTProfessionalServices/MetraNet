
		SELECT distinct
		    /* __GET_POST_BILL_ADJUSTMENT_DETAIL__ */
        au.Amount as UnadjustedAmount,
        adj.CompoundPostBillFedTaxAdjAmt,
        adj.CompoundPostBillStateTaxAdjAmt,
        adj.CompoundPostbillCntyTaxAdjAmt,
        adj.CompoundPostBillLocalTaxAdjAmt,
        adj.CompoundPostBillOtherTaxAdjAmt,
        adj.CompoundPreBillFedTaxAdjAmt,
        adj.CompoundPreBillStateTaxAdjAmt,
        adj.CompoundPrebillCntyTaxAdjAmt,
        adj.CompoundPreBillLocalTaxAdjAmt,
        adj.CompoundPreBillOtherTaxAdjAmt,
        adj.PostbillAdjAmt as AdjustmentAmount,
        au.Amount + adj.PostbillAdjAmt AS AdjustedAmount,
        adj.PostbillAdjAmt + 
          adj.AtomicPostBillFedTaxAdjAmt +
          adj.AtomicPostBillStateTaxAdjAmt +
          adj.AtomicPostbillCntyTaxAdjAmt +
          adj.AtomicPostBillLocalTaxAdjAmt +
          adj.AtomicPostBillOtherTaxAdjAmt as AdjustmentAmountWithTax,
		ajt.id_reason_code ReasonCode,
		    {fn IFNULL(ajtemplatedesc.tx_desc,'')} as "AdjustmentTemplateDisplayName",
		    {fn IFNULL(ajinstancedesc.tx_desc,'')} as "AdjustmentInstanceDisplayName",
		    CASE WHEN (rcbp.nm_name IS NULL) THEN '' ELSE rcbp.nm_name END  AS ReasonCodeName,
		    CASE WHEN (rcbp.nm_desc IS NULL) THEN '' ELSE rcbp.nm_desc END  AS ReasonCodeDescription,
		    CASE WHEN (rcdesc.tx_desc IS NULL) THEN '' ELSE rcdesc.tx_desc END  AS ReasonCodeDisplayName,
		{fn IFNULL(ajt.tx_desc, '')} Description,
		ajt.id_adj_trx as AdjustmentTransactionId
		FROM t_adjustment_transaction ajt
       inner join vw_adjustment_details adj on ajt.id_sess = adj.id_sess
	  		INNER JOIN t_acc_usage au on ajt.id_sess = au.id_sess
		INNER JOIN t_base_props ajtemplatebp ON ajt.id_aj_template = ajtemplatebp.id_prop
		left outer JOIN t_description  ajtemplatedesc ON ajtemplatebp.n_display_name = ajtemplatedesc.id_desc
		LEFT OUTER JOIN t_base_props ajinstancebp ON ajt.id_aj_instance = ajinstancebp.id_prop
		LEFT OUTER JOIN t_description  ajinstancedesc ON ajinstancebp.n_display_name = ajinstancedesc.id_desc
		left outer join t_description des2 on des2.id_lang_code = ajtemplatedesc.id_lang_code and des2.id_desc =  ajinstancebp.n_display_name
		left outer join t_description des3 on des3.id_lang_code = ajinstancedesc.id_lang_code and des3.id_desc =  ajtemplatebp.n_display_name 
		/* resolve adjustment reason code name */
		INNER JOIN t_base_props rcbp ON ajt.id_reason_code = rcbp.id_prop
		INNER JOIN t_description  rcdesc ON rcbp.n_display_name = rcdesc.id_desc
		and {fn IFNULL(ajinstancedesc.id_lang_code,ajtemplatedesc.id_lang_code)} = rcdesc.id_lang_code
		WHERE ajt.c_status = 'A'
		and
		( 
		ajtemplatedesc.id_lang_code=ajinstancedesc.id_lang_code
		or des2.id_lang_code is null
		or des3.id_lang_code is null
		)
		and
		ajt.id_acc_payer = %%ID_ACC%%
		AND ajt.id_usage_interval =  %%ID_INTERVAL%%
		/* realated to CR 9739: only return postbill adjustments
		 IsPostbillADjusted flag doesn't really do it */
		AND adj.n_adjustmenttype = 1
		/* TODO: pass lang code into query */
		AND {fn IFNULL(ajinstancedesc.id_lang_code,ajtemplatedesc.id_lang_code)} = %%LANG_CODE%%
			 