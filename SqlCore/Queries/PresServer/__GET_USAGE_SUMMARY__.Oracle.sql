
  	  select *
      from
      (
      SELECT 
      /* __GET_USAGE_SUMMARY__ */
      bpPo.nm_display_name as ProductOfferingName,
      tbpPiTpl.nm_name AS PriceableItemType,
      COALESCE(bpPiTpl.nm_display_name, tbpPiTpl.nm_display_name) as PriceableItemName,
      bpPiInst.nm_display_name as PriceableItemInstanceName,
      au.id_prod as ProductOfferingId,
      au.id_pi_instance as PriceableItemInstanceId,
      au.id_pi_template as PriceableItemTemplateId,
      piTemplated2.id_template_parent as PriceableItemParentId,
      au.id_view as ViewID,
	  descd2.tx_desc as ViewName,
      'Product' as ViewType,
      COALESCE(bpPiInst.n_display_name, bpPiTpl.n_display_name) as DescriptionID,
      au.am_currency Currency,
      SUM(COALESCE(au.Amount, 0.0)) as Amount,
      /* prebill adjustments */
      SUM(COALESCE(au.AtomicPrebillAdjAmt, 0.0)) as AtomicPrebillAdjAmt,
      SUM(COALESCE(au.CompoundPrebillAdjAmt, 0.0)) as CompoundPrebillAdjAmt,
      SUM(COALESCE(au.CompoundPrebillAdjedAmt, 0.0)) as CompoundPrebillAdjedAmt,
      SUM(COALESCE(au.AtomicPrebillAdjedAmt, 0.0)) as AtomicPrebillAdjedAmt
      ,SUM(au.CompoundPrebillFedTaxAdjAmt) As CompoundPrebillFedTaxAdjAmt
			,SUM(au.CompoundPrebillStateTaxAdjAmt) AS CompoundPrebillStateTaxAdjAmt
			,SUM(au.CompoundPrebillCntyTaxAdjAmt) AS CompoundPrebillCntyTaxAdjAmt
			,SUM(au.CompoundPrebillLocalTaxAdjAmt) AS CompoundPrebillLocalTaxAdjAmt
			,SUM(au.CompoundPrebillOtherTaxAdjAmt) AS CompoundPrebillOtherTaxAdjAmt
			,SUM(au.CompoundPrebillTotalTaxAdjAmt) AS CompoundPrebillTotalTaxAdjAmt
			,SUM(au.CompoundPostbillFedTaxAdjAmt) AS CompoundPostbillFedTaxAdjAmt
			,SUM(au.CompoundPostbillStateTaxAdjAmt) AS CompoundPostbillStateTaxAdjAmt
			,SUM(au.CompoundPostbillCntyTaxAdjAmt) AS CompoundPostbillCntyTaxAdjAmt
			,SUM(au.CompoundPostbillLocalTaxAdjAmt) AS CompoundPostbillLocalTaxAdjAmt
			,SUM(au.CompoundPostbillOtherTaxAdjAmt) AS CompoundPostbillOtherTaxAdjAmt
			,SUM(au.CompoundPostbillTotalTaxAdjAmt) AS CompoundPostbillTotalTaxAdjAmt
			,SUM(au.AtomicPrebillFedTaxAdjAmt) As AtomicPrebillFedTaxAdjAmt
			,SUM(au.AtomicPrebillStateTaxAdjAmt) AS AtomicPrebillStateTaxAdjAmt
			,SUM(au.AtomicPrebillCntyTaxAdjAmt) AS AtomicPrebillCntyTaxAdjAmt
			,SUM(au.AtomicPrebillLocalTaxAdjAmt) AS AtomicPrebillLocalTaxAdjAmt
			,SUM(au.AtomicPrebillOtherTaxAdjAmt) AS AtomicPrebillOtherTaxAdjAmt
			,SUM(au.AtomicPrebillTotalTaxAdjAmt) AS AtomicPrebillTotalTaxAdjAmt
			,SUM(au.AtomicPostbillFedTaxAdjAmt) AS AtomicPostbillFedTaxAdjAmt
			,SUM(au.AtomicPostbillStateTaxAdjAmt) AS AtomicPostbillStateTaxAdjAmt
			,SUM(au.AtomicPostbillCntyTaxAdjAmt) AS AtomicPostbillCntyTaxAdjAmt
			,SUM(au.AtomicPostbillLocalTaxAdjAmt) AS AtomicPostbillLocalTaxAdjAmt
			,SUM(au.AtomicPostbillOtherTaxAdjAmt) AS AtomicPostbillOtherTaxAdjAmt
			,SUM(au.AtomicPostbillTotalTaxAdjAmt) AS AtomicPostbillTotalTaxAdjAmt
      ,SUM(COALESCE(au.Tax_Federal, 0.0) + COALESCE(au.Tax_State, 0.0) + COALESCE(au.Tax_County, 0.0) + COALESCE(au.Tax_Local, 0.0) + COALESCE(au.Tax_Other, 0.0)) as TaxAmount,
      SUM(COALESCE(au.tax_federal, 0.0)) FederalTaxAmount,
      SUM(COALESCE(au.tax_state, 0.0)) StateTaxAmount,
      SUM(COALESCE(au.tax_county, 0.0)) CountyTaxAmount,
      SUM(COALESCE(au.tax_local, 0.0)) LocalTaxAmount,
      SUM(COALESCE(au.tax_other, 0.0)) OtherTaxAmount,
      SUM(au.amount + 
	      /*If implied taxes, then taxes are already included, don't add them again */
	      (case when au.is_implied_tax = 'N' then 
              (COALESCE(au.tax_federal, 0.0) + COALESCE(au.tax_state, 0.0) + COALESCE(au.tax_county, 0.0) + 
                  COALESCE(au.tax_local, 0.0) + COALESCE(au.tax_other, 0.0)) else 0.0 end)
	      /*If informational taxes, then they shouldn't be in the total */
			  - (CASE WHEN (au.tax_informational = 'Y') THEN 
              (COALESCE(au.tax_federal, 0.0) + COALESCE(au.tax_state, 0.0) + COALESCE(au.tax_county, 0.0) + 
                  COALESCE(au.tax_local, 0.0) + COALESCE(au.tax_other, 0.0)) else 0.0 end))
			  AmountWithTax,
      SUM((case when au.is_implied_tax = 'N' then %%DISPLAYAMOUNT%% else au.amount end) 
	  /*If informational taxes, then they shouldn't be in the total */
			  - (CASE WHEN (au.tax_informational = 'Y') THEN 
              (COALESCE(au.tax_federal, 0.0) + COALESCE(au.tax_state, 0.0) + COALESCE(au.tax_county, 0.0) + 
                  COALESCE(au.tax_local, 0.0) + COALESCE(au.tax_other, 0.0)) else 0.0 end)) 
		AS DisplayAmount,
      
      COUNT(1) as Count
      from
      (
        select 
        au.*,
        /* 1. Return Different Amounts: 
         PREBILL ADJUSTMENTS:
         CompoundPrebillAdjAmt  parent and children prebill adjustments for a compound transaction
         AtomicPrebillAdjAmt  parent prebill adjustments for a compound transaction. For an atomic transaction
                                         CompoundPrebillAdjAmt always equals AtomicPrebillAdjAmt
         CompoundPrebillAdjedAmt  Charge Amount + CompoundPrebillAdjAmt
         AtomicPrebillAdjedAmt  Charge amount + parent prebill adjustments for a compound transaction. For an atomic transaction
                                         CompoundPrebillAdjedAmt always equals AtomicPrebillAdjedAmt
         POSTBILL ADJUSTMENTS:
         CompoundPostbillAdjAmt  parent and children postbill adjustments for a compound transaction
         AtomicPostbillAdjAmt  parent postbill adjustments for a compound transaction. For an atomic transaction
                                         CompoundPostbillAdjAmt always equals AtomicPostbillAdjAmt
         CompoundPostbillAdjedAmt  Charge Amount + CompoundPrebillAdjAmt + CompoundPostbillAdjedAmt
         AtomicPostbillAdjedAmt - Charge amount + parent prebill adjustments for a compound transaction +
                                        parent postbill adjustments for a compound transaction. For an atomic transaction
                                        AtomicPostbillAdjedAmt always equals CompoundPostbillAdjedAmt
         PREBILL ADJUSTMENTS: */
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.AdjustmentAmount
            ELSE 0 END
            + 
            COALESCE(ChildPreBillAdjustments.PrebillCompoundAdjAmt, 0.0) AS CompoundPrebillAdjAmt,
        (au.amount + CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.AdjustmentAmount
            ELSE 0 END + COALESCE(ChildPreBillAdjustments.PrebillCompoundAdjAmt, 0.0)) AS CompoundPrebillAdjedAmt,
        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status = 'A')	
	            THEN prebillajs.AdjustmentAmount
	            ELSE 0 END) AS AtomicPrebillAdjAmt,
        (au.amount + (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
	            THEN prebillajs.AdjustmentAmount
	            ELSE 0 END) ) AS AtomicPrebillAdjedAmt,
        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status = 'P')	
	            THEN prebillajs.AdjustmentAmount
	            ELSE 0 END) AS PendingPrebillAdjAmt,
	       /* COMPOUND PREBILL ADJUSTMENTS TO TAXES: */
	      
	      CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.aj_tax_federal
            ELSE 0 END
            + 
            COALESCE(ChildPreBillAdjustments.PrebillCompoundFedTaxAdjAmt, 0.0) AS CompoundPrebillFedTaxAdjAmt,            
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.aj_tax_state
            ELSE 0 END
            + 
            COALESCE(ChildPreBillAdjustments.PrebillCompoundStateTaxAdjAmt, 0.0) AS CompoundPrebillStateTaxAdjAmt,            
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.aj_tax_county
            ELSE 0 END
            + 
            COALESCE(ChildPreBillAdjustments.PrebillCompoundCntyTaxAdjAmt, 0.0) AS CompoundPrebillCntyTaxAdjAmt,            
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.aj_tax_local
            ELSE 0 END
            + 
            COALESCE(ChildPreBillAdjustments.PrebillCompoundLocalTaxAdjAmt, 0.0) AS CompoundPrebillLocalTaxAdjAmt,            
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.aj_tax_other
            ELSE 0 END
            + 
            COALESCE(ChildPreBillAdjustments.PrebillCompoundOtherTaxAdjAmt, 0.0) AS CompoundPrebillOtherTaxAdjAmt,            
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN (prebillajs.aj_tax_federal + prebillajs.aj_tax_state + prebillajs.aj_tax_county + prebillajs.aj_tax_local + prebillajs.aj_tax_other)
            ELSE 0 END
            + 
            COALESCE(ChildPreBillAdjustments.PrebillCompoundTotalTaxAdjAmt, 0.0) AS CompoundPrebillTotalTaxAdjAmt,            
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
            ELSE 0 END + COALESCE(ChildPostBillAdjustments.PostbillCompoundAdjAmt, 0.0) AS CompoundPostbillAdjAmt,
        /* when calculating postbill adjusted amounts, always consider prebill adjusted amounts */
        (au.amount + CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN postbillajs.AdjustmentAmount
            ELSE 0 END  + COALESCE(ChildPostBillAdjustments.PostbillCompoundAdjAmt, 0.0) 
        + 
        /* bring in prebill adjustments */
        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	
            THEN prebillajs.AdjustmentAmount
            ELSE 0 END
            + 
            COALESCE(ChildPreBillAdjustments.PrebillCompoundAdjAmt, 0.0)
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
            COALESCE(ChildPostBillAdjustments.PostbillCompoundFedTaxAdjAmt, 0.0) AS CompoundPostbillFedTaxAdjAmt,            
        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN postbillajs.aj_tax_state
            ELSE 0 END
            + 
            COALESCE(ChildPostBillAdjustments.PostbillCompoundStateTaxAdjAmt, 0.0) AS CompoundPostbillStateTaxAdjAmt,            
        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN postbillajs.aj_tax_county
            ELSE 0 END
            + 
            COALESCE(ChildPostBillAdjustments.PostbillCompoundCntyTaxAdjAmt, 0.0) AS CompoundPostbillCntyTaxAdjAmt,            
        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN postbillajs.aj_tax_local
            ELSE 0 END
            + 
            COALESCE(ChildPostBillAdjustments.PostbillCompoundLocalTaxAdjAmt, 0.0) AS CompoundPostbillLocalTaxAdjAmt,            
        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN postbillajs.aj_tax_other
            ELSE 0 END
            + 
            COALESCE(ChildPostBillAdjustments.PostbillCompoundOtherTaxAdjAmt, 0.0) AS CompoundPostbillOtherTaxAdjAmt,            
        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	
            THEN (postbillajs.aj_tax_federal + postbillajs.aj_tax_state + 
									postbillajs.aj_tax_county + postbillajs.aj_tax_local + postbillajs.aj_tax_other)
            ELSE 0 END
            + 
            COALESCE(ChildPostBillAdjustments.PostbillCompoundTotalTaxAdjAmt, 0.0) AS CompoundPostbillTotalTaxAdjAmt,            
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

        /* 2. Return Adjustment Transaction IDs for both prebill and postbill adjustments (or -1 if none): */
        (CASE WHEN prebillajs.id_adj_trx IS NULL THEN -1 ELSE prebillajs.id_adj_trx END) AS PrebillAdjustmentID,
        (CASE WHEN postbillajs.id_adj_trx IS NULL THEN -1 ELSE postbillajs.id_adj_trx END) AS PostbillAdjustmentID,
        /* 3. Return Adjustment Template IDs for both prebill and postbill adjustments (or -1 if none): */
        (CASE WHEN prebillajs.id_aj_template IS NULL THEN -1 ELSE prebillajs.id_aj_template END) AS PrebillAdjustmentTemplateID,
        (CASE WHEN postbillajs.id_aj_template IS NULL THEN -1 ELSE postbillajs.id_aj_template END) AS PostbillAdjustmentTemplateID,
        /* 4. Return Adjustment Instance IDs for both prebill and postbill adjustments (or -1 if none): */
        (CASE WHEN prebillajs.id_aj_instance IS NULL THEN -1 ELSE prebillajs.id_aj_instance END) AS PrebillAdjustmentInstanceID,
        (CASE WHEN postbillajs.id_aj_instance IS NULL THEN -1 ELSE postbillajs.id_aj_instance END) AS PostbillAdjustmentInstanceID,
        /* 5. Return Adjustment ReasonCode IDs for both prebill and postbill adjustments (or -1 if none): */
        (CASE WHEN prebillajs.id_reason_code IS NULL THEN -1 ELSE prebillajs.id_reason_code END) AS PrebillAdjustmentReasonCodeID,
        (CASE WHEN postbillajs.id_reason_code IS NULL THEN -1 ELSE postbillajs.id_reason_code END) AS PostbillAdjustmentReasonCodeID,
        /* 6. Return Adjustment Descriptions and default descriptions for both prebill and postbill adjustments (or empty string if none): */
        (CASE WHEN prebillajs.tx_desc IS NULL THEN '' ELSE prebillajs.tx_desc END) AS PrebillAdjustmentDescription,
        (CASE WHEN postbillajs.tx_desc IS NULL THEN '' ELSE postbillajs.tx_desc END) AS PostbillAdjustmentDescription,
        (CASE WHEN prebillajs.tx_default_desc IS NULL THEN '' ELSE prebillajs.tx_default_desc END) AS PrebillAdjDefaultDesc,
        (CASE WHEN postbillajs.tx_default_desc IS NULL THEN '' ELSE postbillajs.tx_default_desc END) AS PostbillAdjDefaultDesc,
        /* 7. Return Adjustment Status as following: If transaction interval is either open or soft closed, return prebill adjustment status or 'NA' if none;
            If transaction interval is hard closed, return post bill adjustment status or 'NA' if none */
        (CASE WHEN (taui.tx_status in ('O', 'C') AND  prebillajs.id_adj_trx IS NOT NULL) THEN prebillajs.c_status
         ELSE
        (CASE WHEN (taui.tx_status = 'H' AND postbillajs.id_adj_trx IS NOT NULL) THEN postbillajs.c_status ELSE 'NA' END)
        END) AS AdjustmentStatus,
        /* 8. Return Adjustment Template and Instance Display Names for both prebill and postbill adjustments (or empty string if none): 
            if needed,  we can return name and descriptions from t_base_props
         CASE WHEN (prebillajtemplatedesc.tx_desc IS NULL) THEN '' ELSE prebillajtemplatedesc.tx_desc END  AS PrebillAdjustmentTemplateDisplayName,
         CASE WHEN (postbillajtemplatedesc.tx_desc IS NULL) THEN '' ELSE postbillajtemplatedesc.tx_desc END  AS PostbillAdjustmentTemplateDisplayName,
         CASE WHEN (prebillajinstancedesc.tx_desc IS NULL) THEN '' ELSE prebillajinstancedesc.tx_desc END  AS PrebillAdjustmentInstanceDisplayName,
         CASE WHEN (postbillajinstancedesc.tx_desc IS NULL) THEN '' ELSE postbillajinstancedesc.tx_desc END  AS PostbillAdjustmentInstanceDisplayName,
         9. Return Reason Code Name, Description, Display Name for both prebill and post bill adjustments (or empty string if none)
         CASE WHEN (prebillrcdesc.tx_desc IS NULL) THEN '' ELSE prebillrcdesc.tx_desc END  AS PrebillAdjReasonCodeDispName,
         CASE WHEN (postbillrcdesc.tx_desc IS NULL) THEN '' ELSE postbillrcdesc.tx_desc END  AS PostbillAdjReasonCodeDispName,
         10. Return different flags indicating status of a transaction in regard to adjustments
         Transactions are not considered to be adjusted if status is not 'A' */
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
        /*can not adjust transactions:
        1. in soft closed interval
        2. If transaction is Prebill and it was already prebill adjusted
        3. If transaction is Post bill and it was already postbill adjusted */
        (CASE WHEN	
          (taui.tx_status in	('C')) OR
          (taui.tx_status =	'O' AND prebillajs.id_adj_trx IS NOT NULL) OR
          (taui.tx_status =	'H' AND postbillajs.id_adj_trx IS NOT NULL)
	        then 'N'  else 'Y' end)	AS CanAdjust,
        /* Can not Rebill transactions:
         1. If they are child transactions
         2. in soft closed interval
         3. If transaction is Prebill and it (or it's children) have already been adjusted (need to delete adjustments first)
         4. If transaction is Postbill and it (or it's children) have already been adjusted (need to delete adjustments first)
            Above case will take care of possibility of someone trying to do PostBill rebill over and over again. */
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
        /* Return 'N' if
         1. Transaction hasn't been prebill adjusted yet
         2. Transaction has been prebill adjusted but transaction interval is already closed
         Otherwise return 'Y' */
        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL) THEN
        (CASE WHEN taui.tx_status in ('C', 'H') then 'N'  else 'Y' end)
        ELSE 'N' END)
        AS CanManagePrebillAdjustment,
        /* Return 'N' if
         1. If adjustment is postbill rebill
         2. Transaction hasn't been postbill adjusted
         3. Transaction has been postbill adjusted but payer's interval is already closed
         Otherwise return 'Y' */
        (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL)
        THEN
        (CASE WHEN (ajaui.tx_status in ('C', 'H') OR
        postbillajtype.n_adjustmenttype = 4) then 'N'  else 'Y' end)
        ELSE 'N' END)
        AS CanManagePostbillAdjustment,
        /* This calculates the logical AND of the above two flags.
         CR 9547 fix: Start with postbillajs. If transaction was both
         pre and post bill adjusted, we should be able to manage it
         CR 9548 fix: should not be able to manage REBILL adjustment */
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
        /* return the number of adjusted children
				 or 0 for child transactions of a compound */
        CASE WHEN ChildPreBillAdjustments.NumApprovedChildPrebillAdjed IS NULL 
        THEN 0 
          ELSE ChildPreBillAdjustments.NumApprovedChildPrebillAdjed
        END
        AS NumPrebillAdjustedChildren,
        CASE WHEN ChildPostBillAdjustments.NumApprovedChildPostbillAdjed IS NULL 
        THEN 0 
          ELSE ChildPostBillAdjustments.NumApprovedChildPostbillAdjed
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
        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status ='A') THEN 1 ELSE 0 END) NumApprovedChildPrebillAdjed
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
	        ELSE 0 END) PostbillCompoundCntyTaxAdjAmt,
	        
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
        SUM(CASE WHEN  (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status ='A')  THEN 1 ELSE 0 END)AS NumApprovedChildPostbillAdjed
        from
        t_adjustment_transaction childpostbillajs 
		where childpostbillajs.c_status IN ('A', 'P') AND childpostbillajs.n_adjustmenttype=1
        group by id_parent_sess
        ) 
        ChildPostBillAdjustments on ChildPostBillAdjustments.id_parent_sess=au.id_sess 
        INNER JOIN t_acc_usage_interval taui on au.id_usage_interval = taui.id_usage_interval AND au.id_acc = taui.id_acc
        LEFT OUTER JOIN t_acc_usage_interval ajaui on postbillajs.id_usage_interval = ajaui.id_usage_interval AND postbillajs.id_acc_payer = ajaui.id_acc
        /* need to bring in adjustment type in order to set ManageAdjustments flag to false in case
         of REBILL adjustment type */
        LEFT OUTER JOIN t_adjustment_type prebillajtype on prebillajtype.id_prop = prebillajs.id_aj_type 
        LEFT OUTER JOIN t_adjustment_type postbillajtype on postbillajtype.id_prop = postbillajs.id_aj_type 
	) au
    /* vw_aj_info */
      join t_base_props tbpPiTpl on au.id_pi_template = tbpPiTpl.id_prop
      left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
      left outer join t_vw_base_props bpPo on au.id_prod=bpPo.id_prop and bpPo.id_lang_code=%%ID_LANG%%
      left outer join t_vw_base_props bpPiTpl on au.id_pi_template=bpPiTpl.id_prop and bpPiTpl.id_lang_code=%%ID_LANG%%
      left outer join t_vw_base_props bpPiInst on au.id_pi_instance=bpPiInst.id_prop and bpPiInst.id_lang_code=%%ID_LANG%%
	  inner join t_description descd2 on au.id_view=descd2.id_desc and descd2.id_lang_code=%%ID_LANG%%
      %%FROM_CLAUSE%%
      where
      rownum <= 1001
      and
      %%TIME_PREDICATE%%
      and 
      %%ACCOUNT_PREDICATE%%
      and 
      %%SESSION_PREDICATE%%
      group by
      au.id_prod,
      tbpPiTpl.nm_name,
      tbpPiTpl.nm_display_name,
      bpPo.nm_display_name,
      bpPiTpl.nm_display_name,
      bpPiInst.nm_display_name,
      au.id_pi_instance,
      au.id_pi_template,
      piTemplated2.id_template_parent,
      au.id_view,
      descd2.tx_desc,
      bpPiTpl.n_display_name,
      bpPiInst.n_display_name,
      au.am_currency 
      order by
      ProductOfferingName,
      piTemplated2.id_template_parent desc,
			PriceableItemName,
			au.id_view,
			au.am_currency
      ) foo		
			 