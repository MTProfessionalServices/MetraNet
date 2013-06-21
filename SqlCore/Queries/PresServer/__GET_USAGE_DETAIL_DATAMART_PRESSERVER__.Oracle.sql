
	select * from (
      select  
      /* __GET_USAGE_DETAIL_DATAMART_PRESSERVER__ */
      au.id_view ViewID, 
      au.id_sess SessionID, 
      au.amount Amount,
      au.am_currency Currency, 
      au.id_acc AccountID, 
      /* TODO: place this logic in the vw_mps_acc_mapper view */
      map.displayname DisplayName,
      au.dt_session Timestamp, 
      au.id_pi_template PITemplate,
      au.id_pi_instance PIInstance,
      '%%SESSION_TYPE%%' SessionType,
      ({fn IFNULL(au.tax_federal, 0.0)} + {fn IFNULL(au.tax_state, 0.0)} + {fn IFNULL(au.tax_county, 0.0)} + 
              {fn IFNULL(au.tax_local, 0.0)} + {fn IFNULL(au.tax_other, 0.0)}) TaxAmount, 
      {fn IFNULL(au.tax_federal, 0.0)} FederalTaxAmount,
      {fn IFNULL(au.tax_state, 0.0)} StateTaxAmount,
      {fn IFNULL(au.tax_county, 0.0)} CountyTaxAmount,
      {fn IFNULL(au.tax_local, 0.0)} LocalTaxAmount,
      {fn IFNULL(au.tax_other, 0.0)} OtherTaxAmount,
      au.amount + 
	      /*If implied taxes, then taxes are already included, don't add them again */
	      (case when au.is_implied_tax = 'N' then 
              ({fn IFNULL(au.tax_federal, 0.0)} + {fn IFNULL(au.tax_state, 0.0)} + {fn IFNULL(au.tax_county, 0.0)} + 
                  {fn IFNULL(au.tax_local, 0.0)} + {fn IFNULL(au.tax_other, 0.0)}) else 0.0 end)
	      /*If informational taxes, then they shouldn't be in the total */
			  - (CASE WHEN (au.tax_informational = 'Y') THEN 
              ({fn IFNULL(au.tax_federal, 0.0)} + {fn IFNULL(au.tax_state, 0.0)} + {fn IFNULL(au.tax_county, 0.0)} + 
                  {fn IFNULL(au.tax_local, 0.0)} + {fn IFNULL(au.tax_other, 0.0)}) else 0.0 end)
			  AmountWithTax,
      au.id_usage_interval IntervalID
      ,{fn IFNULL(adjustments.CompoundPrebillAdjAmt, 0.0)} CompoundPrebillAdjAmt
      ,{fn IFNULL(adjustments.CompoundPostbillAdjAmt, 0.0)} CompoundPostbillAdjAmt
      ,{fn IFNULL(adjustments.CompoundPrebillAdjedAmt, au.amount)} CompoundPrebillAdjedAmt
      ,{fn IFNULL(adjustments.CompoundPostbillAdjedAmt, au.amount)} CompoundPostbillAdjedAmt
      ,{fn IFNULL(adjustments.AtomicPrebillAdjAmt, 0.0)} AtomicPrebillAdjAmt
      ,{fn IFNULL(adjustments.AtomicPrebillAdjedAmt, au.amount)} AtomicPrebillAdjedAmt
      ,{fn IFNULL(adjustments.AtomicPostbillAdjAmt, 0.0)} AtomicPostbillAdjAmt
      ,{fn IFNULL(adjustments.AtomicPostbillAdjedAmt, au.amount)} AtomicPostbillAdjedAmt
      ,{fn IFNULL(adjustments.CompoundPrebillFedTaxAdjAmt, 0.0)} CompoundPrebillFedTaxAdjAmt
      ,{fn IFNULL(adjustments.CompoundPrebillStateTaxAdjAmt, 0.0)} CompoundPrebillStateTaxAdjAmt
      ,{fn IFNULL(adjustments.CompoundPrebillCntyTaxAdjAmt, 0.0)} CompoundPrebillCntyTaxAdjAmt
      ,{fn IFNULL(adjustments.CompoundPrebillLocalTaxAdjAmt, 0.0)} CompoundPrebillLocalTaxAdjAmt
      ,{fn IFNULL(adjustments.CompoundPrebillOtherTaxAdjAmt, 0.0)} CompoundPrebillOtherTaxAdjAmt
      ,{fn IFNULL(adjustments.CompoundPrebillTotalTaxAdjAmt, 0.0)} CompoundPrebillTotalTaxAdjAmt
      ,{fn IFNULL(adjustments.CompoundPostbillFedTaxAdjAmt, 0.0)} CompoundPostbillFedTaxAdjAmt
      ,{fn IFNULL(adjustments.CompoundPostbillStateTaxAdjAmt, 0.0)} CompoundPostbillStateTaxAdjAmt
      ,{fn IFNULL(adjustments.CompoundPostbillCntyTaxAdjAmt, 0.0)} CompoundPostbillCntyTaxAdjAmt
      ,{fn IFNULL(adjustments.CompoundPostbillLocalTaxAdjAmt, 0.0)} CompoundPostbillLocalTaxAdjAmt
      ,{fn IFNULL(adjustments.CompoundPostbillOtherTaxAdjAmt, 0.0)} CompoundPostbillOtherTaxAdjAmt
      ,{fn IFNULL(adjustments.CompoundPostbillTotalTaxAdjAmt, 0.0)} CompoundPostbillTotalTaxAdjAmt
      ,{fn IFNULL(adjustments.AtomicPrebillFedTaxAdjAmt, 0.0)} AtomicPrebillFedTaxAdjAmt
      ,{fn IFNULL(adjustments.AtomicPrebillStateTaxAdjAmt, 0.0)} AtomicPrebillStateTaxAdjAmt
      ,{fn IFNULL(adjustments.AtomicPrebillCntyTaxAdjAmt, 0.0)} AtomicPrebillCntyTaxAdjAmt
      ,{fn IFNULL(adjustments.AtomicPrebillLocalTaxAdjAmt, 0.0)} AtomicPrebillLocalTaxAdjAmt
      ,{fn IFNULL(adjustments.AtomicPrebillOtherTaxAdjAmt, 0.0)} AtomicPrebillOtherTaxAdjAmt
      ,{fn IFNULL(adjustments.AtomicPrebillTotalTaxAdjAmt, 0.0)} AtomicPrebillTotalTaxAdjAmt
      ,{fn IFNULL(adjustments.AtomicPostbillFedTaxAdjAmt, 0.0)} AtomicPostbillFedTaxAdjAmt
      ,{fn IFNULL(adjustments.AtomicPostbillStateTaxAdjAmt, 0.0)} AtomicPostbillStateTaxAdjAmt
      ,{fn IFNULL(adjustments.AtomicPostbillCntyTaxAdjAmt, 0.0)} AtomicPostbillCntyTaxAdjAmt
      ,{fn IFNULL(adjustments.AtomicPostbillLocalTaxAdjAmt, 0.0)} AtomicPostbillLocalTaxAdjAmt
      ,{fn IFNULL(adjustments.AtomicPostbillOtherTaxAdjAmt, 0.0)} AtomicPostbillOtherTaxAdjAmt
      ,{fn IFNULL(adjustments.AtomicPostbillTotalTaxAdjAmt, 0.0)} AtomicPostbillTotalTaxAdjAmt
      ,adjustments.IsPrebillTransaction
      ,adjustments.IsAdjusted
      ,adjustments.IsPrebillAdjusted
      ,adjustments.IsPostBillAdjusted
      ,adjustments.CanAdjust
      ,adjustments.CanRebill
      ,adjustments.CanManageAdjustments
      ,adjustments.PrebillAdjustmentID
      ,adjustments.PostbillAdjustmentID
      ,adjustments.IsIntervalSoftClosed
      ,case when au.is_implied_tax = 'N' then %%DISPLAYAMOUNT%% else au.amount end 
	   /*If informational taxes, then they shouldn't be in the total */
			  - (CASE WHEN (au.tax_informational = 'Y') THEN 
              ({fn IFNULL(au.tax_federal, 0.0)} + {fn IFNULL(au.tax_state, 0.0)} + {fn IFNULL(au.tax_county, 0.0)} + 
                  {fn IFNULL(au.tax_local, 0.0)} + {fn IFNULL(au.tax_other, 0.0)}) else 0.0 end)
			AS DisplayAmount
      ,au.is_implied_tax IsTaxInclusive
      ,au.tax_calculated IsTaxCalculated
      ,au.tax_informational IsTaxInformational
       %%SELECT_CLAUSE%%
      from
      %%TABLE_NAME%% pv 
      INNER JOIN t_acc_usage au on au.id_sess = pv.id_sess 	and au.id_usage_interval = pv.id_usage_interval
      left outer join t_mv_adjustments_usagedetail Adjustments on pv.id_sess = Adjustments.id_sess
      and Adjustments.id_usage_interval = pv.id_usage_interval
      INNER JOIN vw_mps_acc_mapper map ON au.id_payee=map.id_acc
      /* additional INNER JOINS on description table (for locale description for enum properties)  */
      /* and for DescdendentPayeerSlice join on acncestor table */
      %%FROM_CLAUSE%%
      where 
      %%ACCOUNT_PREDICATE%% 
      and 
      %%TIME_PREDICATE%% 
      and 
      %%SESSION_PREDICATE%% 
      and 
      %%PRODUCT_PREDICATE%% 
      and au.id_sess <= (select id_sess from t_mv_max_sess)
			/* option(force order) */
	) where rownum <= 1001
	/* %%TOP_ROWS%% */
      /* %WHERE_CLAUSE% */
  and 1=1
  %%EXT%%
	 	 