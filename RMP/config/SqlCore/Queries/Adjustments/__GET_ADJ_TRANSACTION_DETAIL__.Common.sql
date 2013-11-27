
            select 
	            ad.id_adj_trx AdjTrxId,
              ad.amount AdjustmentAmount,
              ad.AdjustmentCreationDate AdjustmentCreationDate,
              ad.am_currency AdjustmentCurrency,
              AdjustmentStatus Status,
              AdjustmentTemplateDisplayName AdjustmentTemplateDisplayName,
              ad.id_aj_type AdjustmentType,  
              AdjustmentUsageInterval AdjustmentUsageInterval,
              ad.AtomicPostbillAdjAmt AtomicPostbillAdjAmt,
              ad.AtomicPostbillAdjedAmt AtomicPostbillAdjedAmt,
              ad.AtomicPostbillCntyTaxAdjAmt AtomicPostbillCntyTaxAdjAmt,
              ad.AtomicPostbillFedTaxAdjAmt AtomicPostbillFedTaxAdjAmt,
              ad.AtomicPostbillLocalTaxAdjAmt AtomicPostbillLocalTaxAdjAmt,
              ad.AtomicPostbillOtherTaxAdjAmt AtomicPostbillOtherTaxAdjAmt,
              ad.AtomicPostbillStateTaxAdjAmt AtomicPostbillStateTaxAdjAmt,
              ad.AtomicPostbillTotalTaxAdjAmt AtomicPostbillTotalTaxAdjAmt,
              ad.AtomicPrebillAdjAmt AtomicPrebillAdjAmt,
              ad.AtomicPrebillAdjedAmt AtomicPrebillAdjedAmt,
              ad.AtomicPrebillCntyTaxAdjAmt AtomicPrebillCntyTaxAdjAmt,
              ad.AtomicPrebillFedTaxAdjAmt AtomicPrebillFedTaxAdjAmt,
              ad.AtomicPrebillLocalTaxAdjAmt AtomicPrebillLocalTaxAdjAmt,
              ad.AtomicPrebillOtherTaxAdjAmt AtomicPrebillOtherTaxAdjAmt,
              ad.AtomicPrebillStateTaxAdjAmt AtomicPrebillStateTaxAdjAmt,
              ad.AtomicPrebillTotalTaxAdjAmt AtomicPrebillTotalTaxAdjAmt,
              ad.CanAdjust CanAdjust,
              ad.CanManageAdjustments CanManageAdjustments,
              ad.CanManagePostbillAdjustment CanManagePostbillAdjustment,
              ad.CanManagePrebillAdjustment CanManagePrebillAdjustment,
              ad.CanRebill CanRebill,
              ad.CompoundPostbillAdjAmt CompoundPostbillAdjAmt,
              ad.CompoundPostbillAdjedAmt CompoundPostbillAdjedAmt,
              ad.CompoundPostbillCntyTaxAdjAmt CompoundPostbillCntyTaxAdjAmt,
              ad.CompoundPostbillFedTaxAdjAmt CompoundPostbillFedTaxAdjAmt,
              ad.CompoundPostbillLocalTaxAdjAmt CompoundPostbillLocalTaxAdjAmt,
              ad.CompoundPostbillOtherTaxAdjAmt CompoundPostbillOtherTaxAdjAmt,
              ad.CompoundPostbillStateTaxAdjAmt CompoundPostbillStateTaxAdjAmt,
              ad.CompoundPostbillTotalTaxAdjAmt CompoundPostbillTotalTaxAdjAmt,
              ad.CompoundPrebillAdjAmt CompoundPrebillAdjAmt,
              ad.CompoundPrebillAdjedAmt CompoundPrebillAdjedAmt,
              ad.CompoundPrebillCntyTaxAdjAmt CompoundPrebillCntyTaxAdjAmt,
              ad.CompoundPrebillFedTaxAdjAmt CompoundPrebillFedTaxAdjAmt,
              ad.CompoundPrebillLocalTaxAdjAmt CompoundPrebillLocalTaxAdjAmt,
              ad.CompoundPrebillOtherTaxAdjAmt CompoundPrebillOtherTaxAdjAmt,
              ad.CompoundPrebillTotalTaxAdjAmt CompoundPrebillTotalTaxAdjAmt,
              ad.CompoundPrebillStateTaxAdjAmt CompoundPrebillStateTaxAdjAmt,
              ad.tax_county CountyTaxAmount,
              ad.tx_desc Description,
              ad.div_amount DivAmount, 
              ad.div_currency DivCurrency, 
              ad.tax_federal FederalTaxAmount,
              LanguageCode LanguageCode,
              ad.tax_local LocalTaxAmount,
              ad.dt_modified ModifedDate,  
              NumPostbillAdjustedChildren NumPostbillAdjustedChildren,
              NumPrebillAdjustedChildren NumPrebillAdjustedChildren,
              ad.tax_other OtherTaxAmount,
              ad.id_parent_sess ParentSessionId,
              PendingPostbillAdjAmt PendingPostbillAdjAmt,
              PendingPrebillAdjAmt PendingPrebillAdjAmt,
              tbp.nm_display_name PITemplateDisplayName,
              PostbillAdjAmt PostbillAdjAmt,
              PostbillAdjDefaultDesc PostbillAdjDefaultDesc,
              PostbillAdjustmentDescription PostbillAdjustmentDescription,
              PrebillAdjAmt PrebillAdjAmt,
              PrebillAdjDefaultDesc PrebillAdjDefaultDesc,
              PrebillAdjustmentDescription PrebillAdjustmentDescription,
              ReasonCodeDescription ReasonCodeDescription,
              ReasonCodeDisplayName ReasonCodeDisplayName,
              ad.id_reason_code ReasonCodeId,
              ReasonCodeName ReasonCodeName,
              ad.id_sess SessionId,
              ad.tax_state StateTaxAmount,
              ad.id_usage_interval UsageIntervalId,
              am.nm_login UserNamePayee,
              am2.nm_login UserNamePayer
    from 
    VW_NOTDELETED_ADJ_DETAILS ad
    inner join t_account_mapper am on ad.id_acc_payer = am.id_acc
    INNER JOIN t_namespace ns on ns.nm_space = am.nm_space 
    AND ns.tx_typ_space IN ('system_mps')
    INNER JOIN t_enum_data ed on upper(ed.nm_enum_data) = ('METRATECH.COM/ACCOUNTCREATION/CONTACTTYPE/BILL-TO')
    inner join t_account_mapper am2 on ad.id_payee = am2.id_acc
    INNER JOIN t_namespace ns2 on ns2.nm_space = am2.nm_space 
    AND ns2.tx_typ_space IN ('system_mps')
    inner join t_base_props tbp on ad.id_pi_template = tbp.id_prop
    WHERE
    /* CR 9689: if transaction interval is closed */
    /* then prebill adjustments can not be managed */
    ((ad.IsPrebill = 'N' AND ad.n_adjustmenttype = 1 AND ad.CanManageAdjustments = 'Y')
    OR
    (ad.IsPrebill = 'Y' AND ad.CanManageAdjustments = 'Y'))
    AND ad.LanguageCode = %%ID_LANG_CODE%%
    and id_SESS = %%SESSION_ID%%    
			