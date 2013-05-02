
select * from (select 
      /* __GET_USAGE_DETAIL_USAGE_HISTORY_SERVICE_2__ */
      au.id_view ViewID, 
      au.id_sess SessionID, 
	  au.id_parent_sess ParentSessionID,
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
              {fn IFNULL(au.tax_local, 0.0)} + {fn IFNULL(au.tax_other, 0.0)}) as TaxAmount, 
      {fn IFNULL(au.tax_federal, 0.0)} FederalTaxAmount,
      {fn IFNULL(au.tax_state, 0.0)} StateTaxAmount,
      {fn IFNULL(au.tax_county, 0.0)} CountyTaxAmount,
      {fn IFNULL(au.tax_local, 0.0)} LocalTaxAmount,
      {fn IFNULL(au.tax_other, 0.0)} OtherTaxAmount,
      (au.amount + 
              {fn IFNULL(au.tax_federal, 0.0)} + {fn IFNULL(au.tax_state, 0.0)} + {fn IFNULL(au.tax_county, 0.0)} + 
              {fn IFNULL(au.tax_local, 0.0)} + {fn IFNULL(au.tax_other, 0.0)}) as AmountWithTax,
      au.id_usage_interval IntervalID
      ,au.CompoundPrebillAdjAmt
      ,au.CompoundPostbillAdjAmt
      ,au.CompoundPrebillAdjedAmt
      ,au.CompoundPostbillAdjedAmt
      ,au.AtomicPrebillAdjAmt
      ,au.AtomicPrebillAdjustedAmt
      ,au.AtomicPostbillAdjAmt
      ,au.AtomicPostbillAdjedAmt
      ,au.CompoundPrebillFedTaxAdjAmt
		,au.CompoundPrebillStateTaxAdjAmt
		,au.CompoundPrebillCntyTaxAdjAmt
		,au.CompoundPrebillLocalTaxAdjAmt
		,au.CompoundPrebillOtherTaxAdjAmt
		,au.CompoundPrebillTotalTaxAdjAmt
		,au.CompoundPostbillFedTaxAdjAmt
		,au.CompoundPostbillStateTaxAdjAmt
		,au.CompoundPostbillCntyTaxAdjAmt
		,au.CompoundPostbillLocalTaxAdjAmt
		,au.CompoundPostbillOtherTaxAdjAmt
		,au.CompoundPostbillTotalTaxAdjAmt
		,au.AtomicPrebillFedTaxAdjAmt
		,au.AtomicPrebillStateTaxAdjAmt
		,au.AtomicPrebillCntyTaxAdjAmt
		,au.AtomicPrebillLocalTaxAdjAmt
		,au.AtomicPrebillOtherTaxAdjAmt
		,au.AtomicPrebillTotalTaxAdjAmt
		,au.AtomicPostbillFedTaxAdjAmt
		,au.AtomicPostbillStateTaxAdjAmt
		,au.AtomicPostbillCntyTaxAdjAmt
		,au.AtomicPostbillLocalTaxAdjAmt
		,au.AtomicPostbillOtherTaxAdjAmt
		,au.AtomicPostbillTotalTaxAdjAmt
      ,au.IsPrebill IsPrebillTransaction
      ,au.IsAdjusted
      ,au.IsPrebillAdjusted
      ,au.IsPostBillAdjusted
      ,au.CanAdjust
      ,au.CanRebill
      ,au.CanManageAdjustments
      ,au.PrebillAdjustmentID
      ,au.PostbillAdjustmentID
      ,au.IsIntervalSoftClosed
      ,{fn IFNULL(%%DISPLAYAMOUNT%%,au.amount)} AS DisplayAmount
      ,au.tax_inclusive IsTaxInclusive
      ,au.tax_calculated isTaxCalculated
      ,au.tax_informational IsTaxInformational
      %%SELECT_CLAUSE%%
      from 
      %%TABLE_NAME%% pv INNER JOIN 
		/* vw_aj_info au  */
			(
        select 
	au.am_currency,                   
        au.amount,
	au.dt_crt,                        
	au.dt_session,                    
	au.id_acc,                        
	au.id_parent_sess,                
	au.id_payee,                      
	au.id_pi_instance,                
	au.id_pi_template,                
	au.id_prod,                       
	au.id_se,                         
	au.id_sess,                       
	au.id_svc,                        
	au.id_usage_interval,             
	au.id_view,                       
	au.tax_county,                    
	au.tax_federal,                   
	au.tax_local,                     
	au.tax_other,                     
	au.tax_state,                     
	au.tx_batch,                      
    au.tx_UID,
    au.tax_inclusive,
    au.tax_calculated,
    au.tax_informational,
        /* 1. Return Different Amounts:  */
        /* PREBILL ADJUSTMENTS: */
        /* CompoundPrebillAdjAmt -- parent and children prebill adjustments for a compound transaction */
        /* AtomicPrebillAdjAmt -- parent prebill adjustments for a compound transaction. For an atomic transaction */
        /*                                 CompoundPrebillAdjAmt always equals AtomicPrebillAdjAmt */
        /* CompoundPrebillAdjAmt -- Charge Amount + CompoundPrebillAdjAmt */
        /* AtomicPrebillAdjAmt -- Charge amount + parent prebill adjustments for a compound transaction. For an atomic transaction */
        /*                                 CompoundPrebillAdjAmt always equals AtomicPrebillAdjAmt */
        /* POSTBILL ADJUSTMENTS: */
        /* CompoundPostbillAdjAmt -- parent and children postbill adjustments for a compound transaction */
        /* AtomicPostbillAdjAmt -- parent postbill adjustments for a compound transaction. For an atomic transaction */
        /*                                 CompoundPostbillAdjAmt always equals AtomicPostbillAdjAmt */
        /* CompoundPostbillAdjedAmt -- Charge Amount + CompoundPrebillAdjAmt + CompoundPostbillAdjAmt */
        /* AtomicPostbillAdjedAmt - Charge amount + parent prebill adjustments for a compound transaction + */
        /*                                parent postbill adjustments for a compound transaction. For an atomic transaction */
        /*                                AtomicPostbillAdjedAmt always equals CompoundPostbillAdjedAmt */
        /* PREBILL ADJUSTMENTS: */
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.AdjustmentAmount
            ELSE 0 END
            + 
            {fn IFNULL(ChildPreBillAdjustments.PrebillCompoundAdjAmt, 0.0)} as CompoundPrebillAdjAmt,
        (au.amount + CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.AdjustmentAmount
            ELSE 0 END + {fn IFNULL(ChildPreBillAdjustments.PrebillCompoundAdjAmt, 0.0)}) AS CompoundPrebillAdjedAmt,
        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status = 'A')	
	         THEN prebillajs.AdjustmentAmount
	         ELSE 0 END) AS AtomicPrebillAdjAmt,
        (au.amount + (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
	            THEN prebillajs.AdjustmentAmount
	            ELSE 0 END) ) AS AtomicPrebillAdjustedAmt,
	            
        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status = 'P')	
	            THEN prebillajs.AdjustmentAmount
	            ELSE 0 END) AS PendingPrebillAdjAmt,
	      
	      /* COMPOUND PREBILL ADJUSTMENTS TO TAXES: */
	      
	      CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.aj_tax_federal
            ELSE 0 END
            + 
            {fn IFNULL(ChildPreBillAdjustments.PrebillCompoundFedTaxAdjAmt, 0.0)} AS CompoundPrebillFedTaxAdjAmt,
            
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.aj_tax_state
            ELSE 0 END
            + 
            {fn IFNULL(ChildPreBillAdjustments.PrebillCompoundStateTaxAdjAmt, 0.0)} AS CompoundPrebillStateTaxAdjAmt,
            
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.aj_tax_county
            ELSE 0 END
            + 
            {fn IFNULL(ChildPreBillAdjustments.PrebillCompoundCntyTaxAdjAmt, 0.0)} AS CompoundPrebillCntyTaxAdjAmt,
            
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.aj_tax_local
            ELSE 0 END
            + 
            {fn IFNULL(ChildPreBillAdjustments.PrebillCompoundLocalTaxAdjAmt, 0.0)} AS CompoundPrebillLocalTaxAdjAmt,
            
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.aj_tax_other
            ELSE 0 END
            + 
            {fn IFNULL(ChildPreBillAdjustments.PrebillCompoundOtherTaxAdjAmt, 0.0)} AS CompoundPrebillOtherTaxAdjAmt,
            
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN (prebillajs.aj_tax_federal + prebillajs.aj_tax_state + prebillajs.aj_tax_county + prebillajs.aj_tax_local + prebillajs.aj_tax_other)
            ELSE 0 END
            + 
            {fn IFNULL(ChildPreBillAdjustments.PrebillCompoundTotalTaxAdjAmt, 0.0)} AS CompoundPrebillTotalTaxAdjAmt,
            
				/* ATOMIC PREBILL ADJUSTMENTS TO TAXES: */
	      
	      (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.aj_tax_federal
            ELSE 0 END) AS AtomicPrebillFedTaxAdjAmt,
            
        (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.aj_tax_state
            ELSE 0 END) AS AtomicPrebillStateTaxAdjAmt,
        
        (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.aj_tax_county
            ELSE 0 END) AS AtomicPrebillCntyTaxAdjAmt,
        
        (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.aj_tax_local
            ELSE 0 END) AS AtomicPrebillLocalTaxAdjAmt,
            
        (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.aj_tax_other
            ELSE 0 END) AS AtomicPrebillOtherTaxAdjAmt,
            
        (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN (prebillajs.aj_tax_federal + prebillajs.aj_tax_state + prebillajs.aj_tax_county + prebillajs.aj_tax_local + prebillajs.aj_tax_other)
            ELSE 0 END) AS AtomicPrebillTotalTaxAdjAmt,
        
        /* POSTBILL ADJUSTMENTS: */
        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN postbillajs.AdjustmentAmount
            ELSE 0 END + {fn IFNULL(ChildPostBillAdjustments.PostbillCompoundAdjAmt, 0.0)} AS CompoundPostbillAdjAmt,
        /* when calculating postbill adjusted amounts, always consider prebill adjusted amounts */
        (au.amount + CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN postbillajs.AdjustmentAmount
            ELSE 0 END  + {fn IFNULL(ChildPostBillAdjustments.PostbillCompoundAdjAmt, 0.0)} 
        + 
        /* bring in prebill adjustments */
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.AdjustmentAmount
            ELSE 0 END
            + 
            {fn IFNULL(ChildPreBillAdjustments.PrebillCompoundAdjAmt, 0.0)}
        ) 
            AS CompoundPostbillAdjedAmt,
        (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status = 'A')	
	            THEN postbillajs.AdjustmentAmount
	            ELSE 0 END) AS AtomicPostbillAdjAmt, 
        /* when calculating postbill adjusted amounts, always consider prebill adjusted amounts */
        (au.amount + (CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
	            THEN postbillajs.AdjustmentAmount
	            ELSE 0 END) 
        /* bring in prebill adjustments */
        +
        (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
	            THEN prebillajs.AdjustmentAmount
	            ELSE 0 END)
	            ) AS AtomicPostbillAdjedAmt,
       (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status = 'P')	
	            THEN postbillajs.AdjustmentAmount
	            ELSE 0 END) AS PendingPostbillAdjAmt,
	      /* COMPOUND POSTBILL ADJUSTMENTS TO TAXES: */
	      
	      CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN postbillajs.aj_tax_federal
            ELSE 0 END
            + 
            {fn IFNULL(ChildPostBillAdjustments.PostbillCompoundFedTaxAdjAmt, 0.0)} AS CompoundPostbillFedTaxAdjAmt,
            
        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN postbillajs.aj_tax_state
            ELSE 0 END
            + 
            {fn IFNULL(ChildPostBillAdjustments.PostbillCompoundStateTaxAdjAmt, 0.0)} AS CompoundPostbillStateTaxAdjAmt,
            
        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN postbillajs.aj_tax_county
            ELSE 0 END
            + 
            {fn IFNULL(ChildPostBillAdjustments.PostbillCompCntyTaxAdjAmt, 0.0)} AS CompoundPostbillCntyTaxAdjAmt,
            
        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN postbillajs.aj_tax_local
            ELSE 0 END
            + 
            {fn IFNULL(ChildPostBillAdjustments.PostbillCompoundLocalTaxAdjAmt, 0.0)} AS CompoundPostbillLocalTaxAdjAmt,
            
        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN postbillajs.aj_tax_other
            ELSE 0 END
            + 
            {fn IFNULL(ChildPostBillAdjustments.PostbillCompoundOtherTaxAdjAmt, 0.0)} AS CompoundPostbillOtherTaxAdjAmt,
            
        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN (postbillajs.aj_tax_federal + postbillajs.aj_tax_state + 
									postbillajs.aj_tax_county + postbillajs.aj_tax_local + postbillajs.aj_tax_other)
            ELSE 0 END
            + 
            {fn IFNULL(ChildPostBillAdjustments.PostbillCompoundTotalTaxAdjAmt, 0.0)} AS CompoundPostbillTotalTaxAdjAmt,
            
				/* ATOMIC POST ADJUSTMENTS TO TAXES: */
	      
	      (CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN postbillajs.aj_tax_federal
            ELSE 0 END) AS AtomicPostbillFedTaxAdjAmt,
            
        (CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN postbillajs.aj_tax_state
            ELSE 0 END) AS AtomicPostbillStateTaxAdjAmt,
        
        (CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN postbillajs.aj_tax_county
            ELSE 0 END) AS AtomicPostbillCntyTaxAdjAmt,
        
        (CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN postbillajs.aj_tax_local
            ELSE 0 END) AS AtomicPostbillLocalTaxAdjAmt,
            
        (CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN postbillajs.aj_tax_other
            ELSE 0 END) AS AtomicPostbillOtherTaxAdjAmt,
            
        (CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN (postbillajs.aj_tax_federal + postbillajs.aj_tax_state + postbillajs.aj_tax_county +
									postbillajs.aj_tax_local + postbillajs.aj_tax_other)
            ELSE 0 END) AS AtomicPostbillTotalTaxAdjAmt,

        /* 2. Return Adjustment Transaction IDs for both prebill and postbill adjustments (or -1 if none):  */
        (CASE WHEN prebillajs.id_adj_trx IS NULL THEN -1 ELSE prebillajs.id_adj_trx END) AS PrebillAdjustmentID,
        (CASE WHEN postbillajs.id_adj_trx IS NULL THEN -1 ELSE postbillajs.id_adj_trx END) AS PostbillAdjustmentID,
        /* 3. Return Adjustment Template IDs for both prebill and postbill adjustments (or -1 if none):  */
        (CASE WHEN prebillajs.id_aj_template IS NULL THEN -1 ELSE prebillajs.id_aj_template END) AS PrebillAdjustmentTemplateID,
        (CASE WHEN postbillajs.id_aj_template IS NULL THEN -1 ELSE postbillajs.id_aj_template END) AS PostbillAdjustmentTemplateID,
        /* 4. Return Adjustment Instance IDs for both prebill and postbill adjustments (or -1 if none):  */
        (CASE WHEN prebillajs.id_aj_instance IS NULL THEN -1 ELSE prebillajs.id_aj_instance END) AS PrebillAdjustmentInstanceID,
        (CASE WHEN postbillajs.id_aj_instance IS NULL THEN -1 ELSE postbillajs.id_aj_instance END) AS PostbillAdjustmentInstanceID,
        /* 5. Return Adjustment ReasonCode IDs for both prebill and postbill adjustments (or -1 if none):  */
        (CASE WHEN prebillajs.id_reason_code IS NULL THEN -1 ELSE prebillajs.id_reason_code END) AS PrebillAdjustmentReasonCodeID,
        (CASE WHEN postbillajs.id_reason_code IS NULL THEN -1 ELSE postbillajs.id_reason_code END) AS PostbillAdjustmentReasonCodeID,
        /* 6. Return Adjustment Descriptions and default descriptions for both prebill and postbill adjustments (or empty string if none):  */
        (CASE WHEN prebillajs.tx_desc IS NULL THEN N' ' ELSE prebillajs.tx_desc END) AS PrebillAdjustmentDescription,
        (CASE WHEN postbillajs.tx_desc IS NULL THEN N' ' ELSE postbillajs.tx_desc END) AS PostbillAdjustmentDescription,
        (CASE WHEN prebillajs.tx_default_desc IS NULL THEN N' ' ELSE prebillajs.tx_default_desc END) AS PrebillAdjustmentDefaultDesc,
        (CASE WHEN postbillajs.tx_default_desc IS NULL THEN N' ' ELSE postbillajs.tx_default_desc END) AS PostbillAdjustmentDefaultDesc,
        /* 7. Return Adjustment Status as following: If transaction interval is either open or soft closed, return prebill adjustment status or 'NA' if none; */
        /*    If transaction interval is hard closed, return post bill adjustment status or 'NA' if none */
        (CASE WHEN (taui.tx_status in ('O', 'C') AND  prebillajs.id_adj_trx IS NOT NULL) THEN prebillajs.c_status
         ELSE
        (CASE WHEN (taui.tx_status = 'H' AND postbillajs.id_adj_trx IS NOT NULL) THEN postbillajs.c_status ELSE 'NA' END)
        END) AS AdjustmentStatus,
        /* 8. Return Adjustment Template and Instance Display Names for both prebill and postbill adjustments (or empty string if none):  */
        /*    if needed,  we can return name and descriptions from t_base_props */
        /* CASE WHEN (prebillajtemplatedesc.tx_desc IS NULL) THEN '' ELSE prebillajtemplatedesc.tx_desc END  AS PrebillAdjTemplateDispName, */
        /* CASE WHEN (postbillajtemplatedesc.tx_desc IS NULL) THEN '' ELSE postbillajtemplatedesc.tx_desc END  AS PostbillAdjTemplateDispName, */
        /* CASE WHEN (prebillajinstancedesc.tx_desc IS NULL) THEN '' ELSE prebillajinstancedesc.tx_desc END  AS PrebillAdjInstanceDispName, */
        /* CASE WHEN (postbillajinstancedesc.tx_desc IS NULL) THEN '' ELSE postbillajinstancedesc.tx_desc END  AS PostbillAdjustmentInstDispName, */
        /* 9. Return Reason Code Name, Description, Display Name for both prebill and post bill adjustments (or empty string if none) */
        /* CASE WHEN (prebillrcdesc.tx_desc IS NULL) THEN '' ELSE prebillrcdesc.tx_desc END  AS PrebillAdjReasonCodeDispName, */
        /* CASE WHEN (postbillrcdesc.tx_desc IS NULL) THEN '' ELSE postbillrcdesc.tx_desc END  AS PostbillAdjReasonCodeDispName, */
        /* 10. Return different flags indicating status of a transaction in regard to adjustments */
        /* Transactions are not considered to be adjusted if status is not 'A' */
        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status = 'A')
        OR (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status = 'A')
	            THEN 'Y' ELSE 'N' END) AS IsAdjusted,
        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status = 'A')	
	            THEN 'Y' ELSE 'N' END) AS IsPrebillAdjusted,
        (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status = 'A')	
	            THEN 'Y' ELSE 'N' END) AS IsPostbillAdjusted,
        (CASE WHEN taui.tx_status in ('N','O')	
		        THEN 'Y' 
		        ELSE 'N' END) AS IsPreBill,
        /* can not adjust transactions: */
        /* 1. in soft closed interval */
        /* 2. If transaction is Prebill and it was already prebill adjusted */
        /* 3. If transaction is Post bill and it was already postbill adjusted */
        (CASE WHEN	
          (taui.tx_status in	('C')) OR
          (taui.tx_status =	'O' AND prebillajs.id_adj_trx IS NOT NULL) OR
          (taui.tx_status =	'H' AND postbillajs.id_adj_trx IS NOT NULL)
	        then 'N'  else 'Y' end)	AS CanAdjust,
        /* Can not Rebill transactions: */
        /* 1. If they are child transactions */
        /* 2. in soft closed interval */
        /* 3. If transaction is Prebill and it (or it's children) have already been adjusted (need to delete adjustments first) */
        /* 4. If transaction is Postbill and it (or it's children) have already been adjusted (need to delete adjustments first) */
        /*    Above case will take care of possibility of someone trying to do PostBill rebill over and over again. */
          (CASE WHEN	
          (au.id_parent_sess IS NOT NULL) 
	        OR
          (taui.tx_status =	('C')) 
          OR
          (taui.tx_status =	'O' AND (prebillajs.id_adj_trx IS NOT NULL 
          OR (ChildPreBillAdjustments.NumChildrenPrebillAdjusted IS NOT NULL AND ChildPreBillAdjustments.NumChildrenPrebillAdjusted > 0)) )
          OR
          (taui.tx_status =	'H' AND (postbillajs.id_adj_trx IS NOT NULL 
          OR (ChildPostBillAdjustments.NumChildrenPostbillAdjusted IS NOT NULL AND ChildPostBillAdjustments.NumChildrenPostbillAdjusted > 0)))
          then 'N' else 'Y' end)	AS CanRebill,
        /* Return 'N' if */
        /* 1. Transaction hasn't been prebill adjusted yet */
        /* 2. Transaction has been prebill adjusted but transaction interval is already closed */
        /* Otherwise return 'Y' */
        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL) THEN
        (CASE WHEN taui.tx_status in ('C', 'H') then 'N'  else 'Y' end)
        ELSE 'N' END)
        AS CanManagePrebillAdjustment,
        /* Return 'N' if */
        /* 1. If adjustment is postbill rebill */
        /* 2. Transaction hasn't been postbill adjusted */
        /* 3. Transaction has been postbill adjusted but payer's interval is already closed */
        /* Otherwise return 'Y' */
        (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL)
        THEN
        (CASE WHEN (ajaui.tx_status in ('C', 'H') OR
        postbillajtype.n_adjustmenttype = 4) then 'N'  else 'Y' end)
        ELSE 'N' END)
        AS CanManagePostbillAdjustment,
        /* This calculates the logical AND of the above two flags. */
        /* CR 9547 fix: Start with postbillajs. If transaction was both */
        /* pre and post bill adjusted, we should be able to manage it */
        /* CR 9548 fix: should not be able to manage REBILL adjustment */
        (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL) THEN
        (CASE WHEN (ajaui.tx_status in ('C', 'H') OR
        postbillajtype.n_adjustmenttype = 4) then 'N'  else 'Y' end)
        ELSE 
        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL) THEN
        (CASE WHEN taui.tx_status in ('C', 'H') then 'N'  else 'Y' end)
        ELSE 'N' END)
        END)
        AS CanManageAdjustments,
        (CASE WHEN (taui.tx_status =	'C' ) THEN 'Y' ELSE 'N' END) As IsIntervalSoftClosed,
        /* return the number of adjusted children */
	/* or 0 for child transactions of a compound */
        CASE WHEN ChildPreBillAdjustments.NumApprovedChildPrebillAdjd IS NULL 
        THEN 0 
          ELSE ChildPreBillAdjustments.NumApprovedChildPrebillAdjd
        END
        AS NumPrebillAdjustedChildren,
        CASE WHEN ChildPostBillAdjustments.NumApprovedChildPostbillAdjd IS NULL 
        THEN 0 
          ELSE ChildPostBillAdjustments.NumApprovedChildPostbillAdjd
        END
        AS NumPostbillAdjustedChildren
        from
        t_acc_usage au 
        left outer join t_adjustment_transaction prebillajs on prebillajs.id_sess=au.id_sess AND prebillajs.c_status IN ('A', 'P') AND prebillajs.n_adjustmenttype=0
        left outer join t_adjustment_transaction postbillajs on postbillajs.id_sess=au.id_sess AND postbillajs.c_status IN ('A', 'P') AND postbillajs.n_adjustmenttype=1
        left outer join
        (
        select id_parent_sess, 
        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')	
	          THEN childprebillajs.AdjustmentAmount
	          ELSE 0 END) PrebillCompoundAdjAmt, 
           /* adjustments to taxes */
	      SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')	
	          THEN childprebillajs.AJ_TAX_FEDERAL
	          ELSE 0 END) PrebillCompoundFedTaxAdjAmt, 
          
	      SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')	
	          THEN childprebillajs.AJ_TAX_STATE
	          ELSE 0 END) PrebillCompoundStateTaxAdjAmt, 
          
	      SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')	
	          THEN childprebillajs.AJ_TAX_COUNTY
	          ELSE 0 END) PrebillCompoundCntyTaxAdjAmt, 
            
	      SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')	
	          THEN childprebillajs.AJ_TAX_LOCAL
	          ELSE 0 END) PrebillCompoundLocalTaxAdjAmt, 
        
          SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')	
	          THEN childprebillajs.AJ_TAX_OTHER
	          ELSE 0 END) PrebillCompoundOtherTaxAdjAmt, 
        
          SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')	
	          THEN (childprebillajs.AJ_TAX_FEDERAL + childprebillajs.AJ_TAX_STATE + childprebillajs.AJ_TAX_COUNTY
	          + childprebillajs.AJ_TAX_LOCAL + childprebillajs.AJ_TAX_OTHER)
	          ELSE 0 END) PrebillCompoundTotalTaxAdjAmt, 
        
        /* Approved or Pending adjusted kids */
        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NULL) THEN 0 ELSE 1 END) NumChildrenPrebillAdjusted,
        /* Approved adjusted kids (I didn't want to change the above flag because it's used for CanRebill flag calculation) */
        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status ='A') THEN 1 ELSE 0 END) NumApprovedChildPrebillAdjd
        from
        t_adjustment_transaction childprebillajs 
		where childprebillajs.c_status IN ('A', 'P') AND childprebillajs.n_adjustmenttype=0
        group by id_parent_sess
        ) 
        ChildPreBillAdjustments on ChildPreBillAdjustments.id_parent_sess=au.id_sess 
        left outer join
        (
        select id_parent_sess, 
        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')	
	        THEN childpostbillajs.AdjustmentAmount
	        ELSE 0 END) PostbillCompoundAdjAmt,
	       /* adjustments to taxes */
	    SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')	
	        THEN childpostbillajs.AJ_TAX_FEDERAL
	        ELSE 0 END) PostbillCompoundFedTaxAdjAmt,
	      
	    SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')	
	        THEN childpostbillajs.AJ_TAX_STATE
	        ELSE 0 END) PostbillCompoundStateTaxAdjAmt,
	      
	    SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')	
	        THEN childpostbillajs.AJ_TAX_COUNTY
	        ELSE 0 END) PostbillCompCntyTaxAdjAmt,
	        
	    SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')	
	        THEN childpostbillajs.AJ_TAX_LOCAL
	        ELSE 0 END) PostbillCompoundLocalTaxAdjAmt,
	        
	    SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')	
	        THEN childpostbillajs.AJ_TAX_OTHER
	        ELSE 0 END) PostbillCompoundOtherTaxAdjAmt,
	      
	    SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')	
	        THEN (childpostbillajs.AJ_TAX_FEDERAL + childpostbillajs.AJ_TAX_STATE + childpostbillajs.AJ_TAX_COUNTY
	          + childpostbillajs.AJ_TAX_LOCAL + childpostbillajs.AJ_TAX_OTHER)
	        ELSE 0 END) PostbillCompoundTotalTaxAdjAmt,
        /* Approved or Pending adjusted kids */
        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NULL) THEN 0 ELSE 1 END) NumChildrenPostbillAdjusted,
        /* Approved adjusted kids (I didn't want to change the above flag because it's used for CanRebill flag calculation) */
        SUM(CASE WHEN  (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status ='A')  THEN 1 ELSE 0 END)AS NumApprovedChildPostbillAdjd
        from
        t_adjustment_transaction childpostbillajs 
		where childpostbillajs.c_status IN ('A', 'P') AND childpostbillajs.n_adjustmenttype=1
        group by id_parent_sess
        ) 
        ChildPostBillAdjustments on ChildPostBillAdjustments.id_parent_sess=au.id_sess 
        INNER JOIN t_acc_usage_interval taui on au.id_usage_interval = taui.id_usage_interval AND au.id_acc = taui.id_acc
        LEFT OUTER JOIN t_acc_usage_interval ajaui on postbillajs.id_usage_interval = ajaui.id_usage_interval AND postbillajs.id_acc_payer = ajaui.id_acc
        /* need to bring in adjustment type in order to set ManageAdjustments flag to false in case */
        /* of REBILL adjustment type */
        LEFT OUTER JOIN t_adjustment_type prebillajtype on prebillajtype.id_prop = prebillajs.id_aj_type 
        LEFT OUTER JOIN t_adjustment_type postbillajtype on postbillajtype.id_prop = postbillajs.id_aj_type 
	) au on pv.id_sess = au.id_sess
      INNER JOIN vw_mps_acc_mapper map ON au.id_payee=map.id_acc

	/* additional INNER JOINS on description table (for locale description for enum properties)  */
	/* and for DescdendentPayeerSlice join on acncestor table */
	%%FROM_CLAUSE%%
	%%ACCOUNT_FROM_CLAUSE%%
	where 
	%%ACCOUNT_PREDICATE%% 
	and 
	%%TIME_PREDICATE%% 
	and 
	%%PRODUCT_PREDICATE%% 
	)
	 	 