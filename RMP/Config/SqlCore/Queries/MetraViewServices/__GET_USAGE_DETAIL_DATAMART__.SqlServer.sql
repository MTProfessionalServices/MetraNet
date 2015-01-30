
	  
  	  select *
      from
      (
      SELECT 
		--__GET_USAGE_DETAIL_DATAMART__
      au.id_view ViewID, 
      au.id_sess SessionID, 
	  au.id_parent_sess ParentSessionID,
      au.amount Amount,
      au.am_currency Currency, 
      au.id_acc AccountID, 
      -- TODO: place this logic in the vw_mps_acc_mapper view
      map.displayname DisplayName,
      au.dt_session Timestamp, 
      au.id_pi_template PITemplate,
      au.id_pi_instance PIInstance,
      '%%SESSION_TYPE%%'  SessionType,
      ({fn IFNULL((au.tax_federal), 0.0)} + {fn IFNULL((au.tax_state), 0.0)} + {fn IFNULL((au.tax_county), 0.0)} + 
              {fn IFNULL((au.tax_local), 0.0)} + {fn IFNULL((au.tax_other), 0.0)}) TaxAmount, 
      {fn IFNULL((au.tax_federal), 0.0)} FederalTaxAmount,
      {fn IFNULL((au.tax_state), 0.0)} StateTaxAmount,
      {fn IFNULL((au.tax_county), 0.0)} CountyTaxAmount,
      {fn IFNULL((au.tax_local), 0.0)} LocalTaxAmount,
      {fn IFNULL((au.tax_other), 0.0)} OtherTaxAmount,
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
           ,CompoundPrebillAdjAmt
           ,CompoundPostbillAdjAmt
           ,CompoundPrebillAdjedAmt
           ,CompoundPostbillAdjedAmt
           ,CompoundPrebillFedTaxAdjAmt
           ,CompoundPrebillStateTaxAdjAmt
           ,CompoundPrebillCntyTaxAdjAmt
           ,CompoundPrebillLocalTaxAdjAmt
           ,CompoundPrebillOtherTaxAdjAmt
           ,CompoundPrebillTotalTaxAdjAmt
           ,CompoundPostbillFedTaxAdjAmt
           ,CompoundPostbillStateTaxAdjAmt
           ,CompoundPostbillCntyTaxAdjAmt
           ,CompoundPostbillLocalTaxAdjAmt
           ,CompoundPostbillOtherTaxAdjAmt
           ,CompoundPostbillTotalTaxAdjAmt
		  ,AtomicPrebillAdjAmt
		  ,AtomicPrebillAdjustedAmt
		  ,AtomicPostbillAdjAmt
		  ,AtomicPostbillAdjedAmt
		  ,AtomicPrebillFedTaxAdjAmt
		  ,AtomicPrebillStateTaxAdjAmt
		  ,AtomicPrebillCntyTaxAdjAmt
		  ,AtomicPrebillLocalTaxAdjAmt
		  ,AtomicPrebillOtherTaxAdjAmt
		  ,AtomicPrebillTotalTaxAdjAmt
		  ,AtomicPostbillFedTaxAdjAmt
		  ,AtomicPostbillStateTaxAdjAmt
		  ,AtomicPostbillCntyTaxAdjAmt
		  ,AtomicPostbillLocalTaxAdjAmt
		  ,AtomicPostbillOtherTaxAdjAmt
		  ,AtomicPostbillTotalTaxAdjAmt
		  ,IsPrebillTransaction
		  ,IsAdjusted
		  ,IsPrebillAdjusted
		  ,IsPostBillAdjusted
		  ,CanAdjust
		  ,CanRebill
		  ,CanManageAdjustments
		  ,PrebillAdjustmentID
		  ,PostbillAdjustmentID
		  ,IsIntervalSoftClosed
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
      left outer join
      (
        select {fn IFNULL((SUM(ChildAdjustments.CompoundPrebillAdjAmt)), 0.0)} + {fn IFNULL((ParentAdjustments.CompoundPrebillAdjAmt), 0.0)} as CompoundPrebillAdjAmt
               ,{fn IFNULL((SUM(ChildAdjustments.CompoundPostbillAdjAmt)), 0.0)} + {fn IFNULL((ParentAdjustments.CompoundPostbillAdjAmt), 0.0)} as CompoundPostbillAdjAmt
               ,{fn IFNULL((SUM(ChildAdjustments.CompoundPrebillAdjedAmt)), 0.0)} + {fn IFNULL((ParentAdjustments.CompoundPrebillAdjedAmt), 0.0)} as CompoundPrebillAdjedAmt
               ,{fn IFNULL((SUM(ChildAdjustments.CompoundPostbillAdjedAmt)), 0.0)} + {fn IFNULL((ParentAdjustments.CompoundPostbillAdjedAmt), 0.0)} as CompoundPostbillAdjedAmt
               ,{fn IFNULL((SUM(ChildAdjustments.CompoundPrebillFedTaxAdjAmt)), 0.0)} + {fn IFNULL((ParentAdjustments.CompoundPrebillFedTaxAdjAmt), 0.0)} as CompoundPrebillFedTaxAdjAmt
               ,{fn IFNULL((SUM(ChildAdjustments.CompoundPrebillStateTaxAdjAmt)), 0.0)} + {fn IFNULL((ParentAdjustments.CompoundPrebillStateTaxAdjAmt), 0.0)} as CompoundPrebillStateTaxAdjAmt
               ,{fn IFNULL((SUM(ChildAdjustments.CompoundPrebillCntyTaxAdjAmt)), 0.0)} + {fn IFNULL((ParentAdjustments.CompoundPrebillCntyTaxAdjAmt), 0.0)} as CompoundPrebillCntyTaxAdjAmt
               ,{fn IFNULL((SUM(ChildAdjustments.CompoundPrebillLocalTaxAdjAmt)), 0.0)} + {fn IFNULL((ParentAdjustments.CompoundPrebillLocalTaxAdjAmt), 0.0)} as CompoundPrebillLocalTaxAdjAmt
               ,{fn IFNULL((SUM(ChildAdjustments.CompoundPrebillOtherTaxAdjAmt)), 0.0)} + {fn IFNULL((ParentAdjustments.CompoundPrebillOtherTaxAdjAmt), 0.0)} as CompoundPrebillOtherTaxAdjAmt
               ,{fn IFNULL((SUM(ChildAdjustments.CompoundPrebillTotalTaxAdjAmt)), 0.0)} + {fn IFNULL((ParentAdjustments.CompoundPrebillTotalTaxAdjAmt), 0.0)} as CompoundPrebillTotalTaxAdjAmt
               ,{fn IFNULL((SUM(ChildAdjustments.CompoundPostbillFedTaxAdjAmt)), 0.0)} + {fn IFNULL((ParentAdjustments.CompoundPostbillFedTaxAdjAmt), 0.0)} as CompoundPostbillFedTaxAdjAmt
               ,{fn IFNULL((SUM(ChildAdjustments.CompoundPostbillStateTaxAdjAmt)), 0.0)} + {fn IFNULL((ParentAdjustments.CompoundPostbillStateTaxAdjAmt), 0.0)} as CompoundPostbillStateTaxAdjAmt
               ,{fn IFNULL((SUM(ChildAdjustments.CompoundPostbillCntyTaxAdjAmt)), 0.0)} + {fn IFNULL((ParentAdjustments.CompoundPostbillCntyTaxAdjAmt), 0.0)} as CompoundPostbillCntyTaxAdjAmt
               ,{fn IFNULL((SUM(ChildAdjustments.CompoundPostbillLocalTaxAdjAmt)), 0.0)} + {fn IFNULL((ParentAdjustments.CompoundPostbillLocalTaxAdjAmt), 0.0)} as CompoundPostbillLocalTaxAdjAmt
               ,{fn IFNULL((SUM(ChildAdjustments.CompoundPostbillOtherTaxAdjAmt)), 0.0)} + {fn IFNULL((ParentAdjustments.CompoundPostbillOtherTaxAdjAmt), 0.0)} as CompoundPostbillOtherTaxAdjAmt
               ,{fn IFNULL((SUM(ChildAdjustments.CompoundPostbillTotalTaxAdjAmt)), 0.0)} + {fn IFNULL((ParentAdjustments.CompoundPostbillTotalTaxAdjAmt), 0.0)} as CompoundPostbillTotalTaxAdjAmt
			  ,{fn IFNULL(ParentAdjustments.AtomicPrebillAdjAmt, 0.0)} AtomicPrebillAdjAmt
			  ,{fn IFNULL(ParentAdjustments.AtomicPrebillAdjedAmt, au.amount)} AtomicPrebillAdjustedAmt
			  ,{fn IFNULL(ParentAdjustments.AtomicPostbillAdjAmt, 0.0)} AtomicPostbillAdjAmt
			  ,{fn IFNULL(ParentAdjustments.AtomicPostbillAdjedAmt, au.amount)} AtomicPostbillAdjedAmt
			  ,{fn IFNULL(ParentAdjustments.AtomicPrebillFedTaxAdjAmt, 0.0)} AtomicPrebillFedTaxAdjAmt
			  ,{fn IFNULL(ParentAdjustments.AtomicPrebillStateTaxAdjAmt, 0.0)} AtomicPrebillStateTaxAdjAmt
			  ,{fn IFNULL(ParentAdjustments.AtomicPrebillCntyTaxAdjAmt, 0.0)} AtomicPrebillCntyTaxAdjAmt
			  ,{fn IFNULL(ParentAdjustments.AtomicPrebillLocalTaxAdjAmt, 0.0)} AtomicPrebillLocalTaxAdjAmt
			  ,{fn IFNULL(ParentAdjustments.AtomicPrebillOtherTaxAdjAmt, 0.0)} AtomicPrebillOtherTaxAdjAmt
			  ,{fn IFNULL(ParentAdjustments.AtomicPrebillTotalTaxAdjAmt, 0.0)} AtomicPrebillTotalTaxAdjAmt
			  ,{fn IFNULL(ParentAdjustments.AtomicPostbillFedTaxAdjAmt, 0.0)} AtomicPostbillFedTaxAdjAmt
			  ,{fn IFNULL(ParentAdjustments.AtomicPostbillStateTaxAdjAmt, 0.0)} AtomicPostbillStateTaxAdjAmt
			  ,{fn IFNULL(ParentAdjustments.AtomicPostbillCntyTaxAdjAmt, 0.0)} AtomicPostbillCntyTaxAdjAmt
			  ,{fn IFNULL(ParentAdjustments.AtomicPostbillLocalTaxAdjAmt, 0.0)} AtomicPostbillLocalTaxAdjAmt
			  ,{fn IFNULL(ParentAdjustments.AtomicPostbillOtherTaxAdjAmt, 0.0)} AtomicPostbillOtherTaxAdjAmt
			  ,{fn IFNULL(ParentAdjustments.AtomicPostbillTotalTaxAdjAmt, 0.0)} AtomicPostbillTotalTaxAdjAmt
			  ,{fn IFNULL(ParentAdjustments.IsPrebillTransaction, 'N')} IsPrebillTransaction
			  ,{fn IFNULL(ParentAdjustments.IsAdjusted, 'N')} IsAdjusted
			  ,{fn IFNULL(ParentAdjustments.IsPrebillAdjusted, 'N')} IsPrebillAdjusted
			  ,{fn IFNULL(ParentAdjustments.IsPostBillAdjusted, 'N')} IsPostBillAdjusted
			  ,{fn IFNULL(ParentAdjustments.CanAdjust, 'Y')} CanAdjust
			  ,{fn IFNULL(ParentAdjustments.CanRebill, 'Y')} CanRebill
			  ,{fn IFNULL(ParentAdjustments.CanManageAdjustments, 'N')} CanManageAdjustments
			  ,{fn IFNULL(ParentAdjustments.PrebillAdjustmentID, -1)} PrebillAdjustmentID
			  ,{fn IFNULL(ParentAdjustments.PostbillAdjustmentID, -1)} PostbillAdjustmentID
			  ,{fn IFNULL(ParentAdjustments.IsIntervalSoftClosed, 'N')} IsIntervalSoftClosed
              ,au.id_sess as AdjustmentSessionID
              ,au.id_usage_interval
              ,au.is_implied_tax
              ,au.tax_calculated
              ,au.tax_informational
         from t_acc_usage au
         inner join %%TABLE_NAME%% pv_c on au.id_sess = pv_c.id_sess and au.id_usage_interval = pv_c.id_usage_interval
         left outer join t_mv_adjustments_usagedetail ParentAdjustments on ParentAdjustments.id_sess = au.id_sess and ParentAdjustments.id_usage_interval = au.id_usage_interval
         left outer join t_acc_usage au_c on au_c.id_parent_sess = pv_c.id_sess
         left outer join t_mv_adjustments_usagedetail ChildAdjustments on ChildAdjustments.id_sess = au_c.id_sess
		%%ACCOUNT_FROM_CLAUSE%%
		where 
		%%ACCOUNT_PREDICATE%% 
		and 
		%%TIME_PREDICATE%% 
		and 
		%%PRODUCT_PREDICATE%% 		 
         group by 
		   au.id_acc
           ,au.id_sess
           ,au.id_usage_interval
           ,au.id_pi_instance
           ,au.id_view
           ,au.amount
		   ,au.is_implied_tax
           ,au.tax_calculated
           ,au.tax_informational
           ,ParentAdjustments.CompoundPrebillAdjAmt
           ,ParentAdjustments.CompoundPostbillAdjAmt
           ,ParentAdjustments.CompoundPrebillAdjedAmt
           ,ParentAdjustments.CompoundPostbillAdjedAmt
           ,ParentAdjustments.CompoundPrebillFedTaxAdjAmt
           ,ParentAdjustments.CompoundPrebillStateTaxAdjAmt
           ,ParentAdjustments.CompoundPrebillCntyTaxAdjAmt
           ,ParentAdjustments.CompoundPrebillLocalTaxAdjAmt
           ,ParentAdjustments.CompoundPrebillOtherTaxAdjAmt
           ,ParentAdjustments.CompoundPrebillTotalTaxAdjAmt
           ,ParentAdjustments.CompoundPostbillFedTaxAdjAmt
           ,ParentAdjustments.CompoundPostbillStateTaxAdjAmt
           ,ParentAdjustments.CompoundPostbillCntyTaxAdjAmt
           ,ParentAdjustments.CompoundPostbillLocalTaxAdjAmt
           ,ParentAdjustments.CompoundPostbillOtherTaxAdjAmt
           ,ParentAdjustments.CompoundPostbillTotalTaxAdjAmt
		  ,ParentAdjustments.AtomicPrebillAdjAmt
		  ,ParentAdjustments.AtomicPrebillAdjedAmt
		  ,ParentAdjustments.AtomicPostbillAdjAmt
		  ,ParentAdjustments.AtomicPostbillAdjedAmt
		  ,ParentAdjustments.AtomicPrebillFedTaxAdjAmt
		  ,ParentAdjustments.AtomicPrebillStateTaxAdjAmt
		  ,ParentAdjustments.AtomicPrebillCntyTaxAdjAmt
		  ,ParentAdjustments.AtomicPrebillLocalTaxAdjAmt
		  ,ParentAdjustments.AtomicPrebillOtherTaxAdjAmt
		  ,ParentAdjustments.AtomicPrebillTotalTaxAdjAmt
		  ,ParentAdjustments.AtomicPostbillFedTaxAdjAmt
		  ,ParentAdjustments.AtomicPostbillStateTaxAdjAmt
		  ,ParentAdjustments.AtomicPostbillCntyTaxAdjAmt
		  ,ParentAdjustments.AtomicPostbillLocalTaxAdjAmt
		  ,ParentAdjustments.AtomicPostbillOtherTaxAdjAmt
		  ,ParentAdjustments.AtomicPostbillTotalTaxAdjAmt
		  ,ParentAdjustments.IsPrebillTransaction
		  ,ParentAdjustments.IsAdjusted
		  ,ParentAdjustments.IsPrebillAdjusted
		  ,ParentAdjustments.IsPostBillAdjusted
		  ,ParentAdjustments.CanAdjust
		  ,ParentAdjustments.CanRebill
		  ,ParentAdjustments.CanManageAdjustments
		  ,ParentAdjustments.PrebillAdjustmentID
		  ,ParentAdjustments.PostbillAdjustmentID
		  ,ParentAdjustments.IsIntervalSoftClosed
		  
      ) Adjustments on Adjustments.AdjustmentSessionID = pv.id_sess
      and Adjustments.id_usage_interval = pv.id_usage_interval
      INNER JOIN vw_mps_acc_mapper map ON au.id_payee=map.id_acc
      -- additional INNER JOINS on description table (for locale description for enum properties) 
      -- and for DescdendentPayeerSlice join on acncestor table    
      %%FROM_CLAUSE%%
	  %%ACCOUNT_FROM_CLAUSE%%
      where 
      %%ACCOUNT_PREDICATE%% 
      and 
      %%TIME_PREDICATE%% 
      and 
      %%PRODUCT_PREDICATE%% 
      and au.id_sess <= (select id_sess from t_mv_max_sess)      
      ) foo	
      
  /*__QUERY_To_RETURN_COUNT__*/ 
	 select au.id_sess,au.id_usage_interval
		from  %%TABLE_NAME%% pv 
      INNER JOIN t_acc_usage au on au.id_sess = pv.id_sess 	and au.id_usage_interval = pv.id_usage_interval
	  %%FROM_CLAUSE%%
	  %%ACCOUNT_FROM_CLAUSE%%
      where 
      %%ACCOUNT_PREDICATE%% 
      and 
      %%TIME_PREDICATE%% 
      and 
      %%PRODUCT_PREDICATE%% 
      and au.id_sess <= (select id_sess from t_mv_max_sess)      
	  
	 