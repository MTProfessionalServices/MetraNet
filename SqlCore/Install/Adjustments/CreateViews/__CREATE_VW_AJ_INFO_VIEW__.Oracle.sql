
                        create or replace force view VW_AJ_INFO as select
                        au.ID_SESS, au.TX_UID, au.ID_ACC, au.ID_PAYEE, au.ID_VIEW, au.ID_USAGE_INTERVAL, au.ID_PARENT_SESS, 
                        NVL(au.ID_PROD, (Select id_prod from t_acc_usage where id_parent_sess = au.id_sess where rownum = 1)),
						au.ID_SVC, au.DT_SESSION, au.AMOUNT, au.AM_CURRENCY, au.DT_CRT, au.TX_BATCH,						
                        au.TAX_FEDERAL, au.TAX_STATE, au.TAX_COUNTY, au.TAX_LOCAL, au.TAX_OTHER, au.ID_PI_INSTANCE, 
                        au.ID_PI_TEMPLATE, au.ID_SE, au.DIV_CURRENCY, au.DIV_AMOUNT, au.is_implied_tax, au.tax_informational
                        ,CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
                        THEN prebillajs.AdjustmentAmount
                        ELSE 0 END
                        +
                        NVL(ChildPreBillAdjustments.PrebillCompoundAdjAmt, 0.0) AS CompoundPrebillAdjAmt,
                        (au.amount + CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
                        THEN prebillajs.AdjustmentAmount
                        ELSE 0 END) + NVL(ChildPreBillAdjustments.PrebillCompoundAdjAmt, 0.0) AS CompoundPrebillAdjedAmt,
                        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status = 'A')
                        THEN prebillajs.AdjustmentAmount
                        ELSE 0 END) AS AtomicPrebillAdjAmt,
                        (au.amount + (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
                        THEN prebillajs.AdjustmentAmount
                        ELSE 0 END) ) AS AtomicPrebillAdjedAmt,
                        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status = 'P')
                        THEN prebillajs.AdjustmentAmount
                        ELSE 0 END) AS PendingPrebillAdjAmt,
                        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
                        THEN prebillajs.aj_tax_federal
                        ELSE 0 END
                        +
                        NVL(ChildPreBillAdjustments.PrebillCompFedTaxAdjAmt, 0.0) AS CompoundPrebillFedTaxAdjAmt,
                        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
                        THEN prebillajs.aj_tax_state
                        ELSE 0 END
                        +
                        NVL(ChildPreBillAdjustments.PrebillCompStateTaxAdjAmt, 0.0) AS CompoundPrebillStateTaxAdjAmt,
                        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
                        THEN prebillajs.aj_tax_county
                        ELSE 0 END
                        +
                        NVL(ChildPreBillAdjustments.PrebillCompCntyTaxAdjAmt, 0.0) AS CompoundPrebillCntyTaxAdjAmt,
                        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
                        THEN prebillajs.aj_tax_local
                        ELSE 0 END
                        +
                        NVL(ChildPreBillAdjustments.PrebillCompLocalTaxAdjAmt, 0.0) AS CompoundPrebillLocalTaxAdjAmt,
                        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
                        THEN prebillajs.aj_tax_other
                        ELSE 0 END
                        +
                        NVL(ChildPreBillAdjustments.PrebillCompOtherTaxAdjAmt, 0.0) AS CompoundPrebillOtherTaxAdjAmt,
                        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
                        THEN (prebillajs.aj_tax_federal + prebillajs.aj_tax_state + prebillajs.aj_tax_county + prebillajs.aj_tax_local + prebillajs.aj_tax_other)
                        ELSE 0 END
                        +
                        NVL(ChildPreBillAdjustments.PrebillCompTotalTaxAdjAmt, 0.0) AS CompoundPrebillTotalTaxAdjAmt,
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
                        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
                        THEN postbillajs.AdjustmentAmount
                        ELSE 0 END + NVL(ChildPostBillAdjustments.PostbillCompoundAdjAmt, 0.0) AS CompoundPostbillAdjAmt,
                        (au.amount + CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
                        THEN postbillajs.AdjustmentAmount
                        ELSE 0 END  + NVL(ChildPostBillAdjustments.PostbillCompoundAdjAmt, 0.0)
                        +
                        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
                        THEN prebillajs.AdjustmentAmount
                        ELSE 0 END
                        +
                        NVL(ChildPreBillAdjustments.PrebillCompoundAdjAmt, 0.0)
                        )
                        AS CompoundPostbillAdjedAmt,
                        (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status = 'A')
                        THEN postbillajs.AdjustmentAmount
                        ELSE 0 END) AS AtomicPostbillAdjAmt,
                        (au.amount + (CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
                        THEN postbillajs.AdjustmentAmount
                        ELSE 0 END)
                        +
                        (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')
                        THEN prebillajs.AdjustmentAmount
                        ELSE 0 END)
                        ) AS AtomicPostbillAdjedAmt,
                        (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status = 'P')
                        THEN postbillajs.AdjustmentAmount
                        ELSE 0 END) AS PendingPostbillAdjAmt,
                        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
                        THEN postbillajs.aj_tax_federal
                        ELSE 0 END
                        +
                        NVL(ChildPostBillAdjustments.PostbillCompFedTaxAdjAmt, 0.0) AS CompoundPostbillFedTaxAdjAmt,
                        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
                        THEN postbillajs.aj_tax_state
                        ELSE 0 END
                        +
                        NVL(ChildPostBillAdjustments.PostbillCompStateTaxAdjAmt, 0.0) AS CompoundPostbillStateTaxAdjAmt,
                        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
                        THEN postbillajs.aj_tax_county
                        ELSE 0 END
                        +
                        NVL(ChildPostBillAdjustments.PostbillCompCntyTaxAdjAmt, 0.0) AS CompoundPostbillCntyTaxAdjAmt,
                        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
                        THEN postbillajs.aj_tax_local
                        ELSE 0 END
                        +
                        NVL(ChildPostBillAdjustments.PostbillCompLocalTaxAdjAmt, 0.0) AS CompoundPostbillLocalTaxAdjAmt,
                        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
                        THEN postbillajs.aj_tax_other
                        ELSE 0 END
                        +
                        NVL(ChildPostBillAdjustments.PostbillCompOtherTaxAdjAmt, 0.0) AS CompoundPostbillOtherTaxAdjAmt,
                        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')
                        THEN (postbillajs.aj_tax_federal + postbillajs.aj_tax_state +
                        postbillajs.aj_tax_county + postbillajs.aj_tax_local + postbillajs.aj_tax_other)
                        ELSE 0 END
                        +
                        NVL(ChildPostBillAdjustments.PostbillCompTotalTaxAdjAmt, 0.0) AS CompoundPostbillTotalTaxAdjAmt,
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
                        (CASE WHEN prebillajs.tx_desc IS NULL THEN translate('' using nchar_cs) ELSE prebillajs.tx_desc END) AS PrebillAdjustmentDescription,
                        (CASE WHEN postbillajs.tx_desc IS NULL THEN translate('' using nchar_cs) ELSE postbillajs.tx_desc END) AS PostbillAdjustmentDescription,
                        (CASE WHEN prebillajs.tx_default_desc IS NULL THEN translate('' using nchar_cs) ELSE prebillajs.tx_default_desc END) AS PrebillAdjDefaultDesc,
                        (CASE WHEN postbillajs.tx_default_desc IS NULL THEN translate('' using nchar_cs) ELSE postbillajs.tx_default_desc END) AS PostbillAdjDefaultDesc,
                        /* 7. Return Adjustment Status as following: If transaction interval is either open or soft closed, return prebill adjustment status or 'NA' if none;
                            If transaction interval is hard closed, return post bill adjustment status or 'NA' if none */
                        (CASE WHEN (taui.tx_status in ('O', 'C') AND  prebillajs.id_adj_trx IS NOT NULL) THEN prebillajs.c_status
                         ELSE
                        (CASE WHEN (taui.tx_status = 'H' AND postbillajs.id_adj_trx IS NOT NULL) THEN postbillajs.c_status ELSE 'NA' END)
                        END) AS AdjustmentStatus,
                        /* 8. Return Adjustment Template and Instance Display Names for both prebill and postbill adjustments (or empty string if none):
                            if needed,  we can return name and descriptions from t_base_props
                         CASE WHEN (prebillajtemplatedesc.tx_desc IS NULL) THEN '' ELSE prebillajtemplatedesc.tx_desc END  AS PrebillAdjTemplateDisplayName,
                         CASE WHEN (postbillajtemplatedesc.tx_desc IS NULL) THEN '' ELSE postbillajtemplatedesc.tx_desc END  AS PostbillAdjTemplateDisplayName,
                         CASE WHEN (prebillajinstancedesc.tx_desc IS NULL) THEN '' ELSE prebillajinstancedesc.tx_desc END  AS PrebillAdjInstanceDisplayName,
                         CASE WHEN (postbillajinstancedesc.tx_desc IS NULL) THEN '' ELSE postbillajinstancedesc.tx_desc END  AS PostbillAdjInstanceDisplayName,
                         9. Return Reason Code Name, Description, Display Name for both prebill and post bill adjustments (or empty string if none)
                         CASE WHEN (prebillrcdesc.tx_desc IS NULL) THEN '' ELSE prebillrcdesc.tx_desc END  AS PrebillAdjReasonCodeDispName,
                         CASE WHEN (postbillrcdesc.tx_desc IS NULL) THEN '' ELSE postbillrcdesc.tx_desc END  AS PostbillAdjReasonCodeDispName,
                         10. Return different flags indicating status of a transaction in regard to adjustments
                         Transactions are not considered to be adjusted if status is not 'A'
                         CR 11785 - Now we are checking for Pending also */
                        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status in ('A','P'))
                        OR (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status in ('A','P'))
                        THEN 'Y' ELSE 'N' END) AS IsAdjusted,
                        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status  in ('A','P'))
                        THEN 'Y' ELSE 'N' END) AS IsPrebillAdjusted,
                        (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status  in ('A','P'))
                        THEN 'Y' ELSE 'N' END) AS IsPostbillAdjusted,
                        (CASE WHEN (taui.tx_status = 'O')	
                		        THEN 'Y' 
                		        ELSE 'N' END) AS IsPreBill,
                        /* can not adjust transactions:
                        1. in soft closed interval
                        2. If transaction is Prebill and it was already prebill adjusted
                        3. If transaction is Post bill and it was already postbill adjusted */
                        (CASE WHEN	
                          (taui.tx_status in ('C')) OR
                          (taui.tx_status = 'O' AND prebillajs.id_adj_trx IS NOT NULL) OR
                          (taui.tx_status = 'H' AND postbillajs.id_adj_trx IS NOT NULL)
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
                          (taui.tx_status =('C')) 
                          OR
                          (taui.tx_status =	'O' AND (prebillajs.id_adj_trx IS NOT NULL 
                          OR (ChildPreBillAdjustments.NumChildrenPrebillAdjusted IS NOT NULL AND ChildPreBillAdjustments.NumChildrenPrebillAdjusted > 0)) )
                          OR
                          (taui.tx_status = 'H' AND (postbillajs.id_adj_trx IS NOT NULL 
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
                       (CASE WHEN (ajaui.tx_status in ('C') OR
                					(ajaui.tx_status  = 'H' AND postbillajs.c_status = 'A') OR
                        postbillajtype.n_adjustmenttype = 4) then 'N'  else 'Y' end)
                        ELSE 'N' END)
                        AS CanManagePostbillAdjustment,
                        /* This calculates the logical AND of the above two flags.
                         CR 9547 fix: Start with postbillajs. If transaction was both
                         pre and post bill adjusted, we should be able to manage it
                         CR 9548 fix: should not be able to manage REBILL adjustment */
                        
                        (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL) THEN
                        /* CR 11775: we want to allow adjustment management
                         if adjustment is pending but interval is hard closed */
                        (CASE WHEN (ajaui.tx_status in ('C') OR
                					(ajaui.tx_status  = 'H' AND postbillajs.c_status = 'A') OR
                        postbillajtype.n_adjustmenttype = 4) then 'N'  else 'Y' end)
                        ELSE 
                        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL) THEN
                        (CASE WHEN taui.tx_status in ('C', 'H') then 'N'  else 'Y' end)
                        ELSE 'N' END)
                        END)
                        AS CanManageAdjustments,
                        (CASE WHEN (taui.tx_status = 'C' ) THEN 'Y' ELSE 'N' END) As IsIntervalSoftClosed,
                        /* return the number of adjusted children
                         or 0 for child transactions of a compound */
                        CASE WHEN ChildPreBillAdjustments.NumApprovedChildPrebillAdj IS NULL
                        THEN 0
                        ELSE ChildPreBillAdjustments.NumApprovedChildPrebillAdj
                        END
                        AS NumPrebillAdjustedChildren,
                        
                        CASE WHEN ChildPostBillAdjustments.NumApprovedChildPostbillAdj IS NULL
                        THEN 0
                        ELSE ChildPostBillAdjustments.NumApprovedChildPostbillAdj
                        END
                        AS NumPostbillAdjustedChildren
                        FROM
                        t_acc_usage au
                        left outer join t_adjustment_transaction prebillajs on prebillajs.id_sess=au.id_sess AND prebillajs.c_status IN ('A', 'P') AND prebillajs.n_adjustmenttype=0
                        left outer join t_adjustment_transaction postbillajs on postbillajs.id_sess=au.id_sess AND postbillajs.c_status IN ('A', 'P') AND postbillajs.n_adjustmenttype=1
                        left outer join
                        (
                        select id_parent_sess,
                        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A') THEN childprebillajs.AdjustmentAmount ELSE 0 END) PrebillCompoundAdjAmt,
                        /* adjustments to taxes */
                        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')
	                        THEN childprebillajs.AJ_TAX_FEDERAL
		                    ELSE 0 END) PrebillCompFedTaxAdjAmt,
                        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')
			                THEN childprebillajs.AJ_TAX_STATE
	                        ELSE 0 END) PrebillCompStateTaxAdjAmt,
                        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')
		                    THEN childprebillajs.AJ_TAX_COUNTY
			                ELSE 0 END) PrebillCompCntyTaxAdjAmt,
                        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')
							THEN childprebillajs.AJ_TAX_LOCAL
							ELSE 0 END) PrebillCompLocalTaxAdjAmt,
                        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')
							THEN childprebillajs.AJ_TAX_OTHER
							ELSE 0 END) PrebillCompOtherTaxAdjAmt,
                        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')
							THEN (childprebillajs.AJ_TAX_FEDERAL + childprebillajs.AJ_TAX_STATE + childprebillajs.AJ_TAX_COUNTY
							+ childprebillajs.AJ_TAX_LOCAL + childprebillajs.AJ_TAX_OTHER)
							ELSE 0 END) PrebillCompTotalTaxAdjAmt,
                        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NULL) THEN 0 ELSE 1 END) NumChildrenPrebillAdjusted,
                        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status ='A') THEN 1 ELSE 0 END) NumApprovedChildPrebillAdj
                        from
							t_adjustment_transaction childprebillajs
						where
							childprebillajs.c_status IN ('A', 'P') AND childprebillajs.n_adjustmenttype=0
                        group by id_parent_sess
                        ) ChildPreBillAdjustments on ChildPreBillAdjustments.id_parent_sess=au.id_sess
						left outer join
                        (
                        select id_parent_sess,
                        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A') THEN childpostbillajs.AdjustmentAmount ELSE 0 END) PostbillCompoundAdjAmt,
                        /* adjustments to taxes */
                        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')
                        THEN childpostbillajs.AJ_TAX_FEDERAL
                        ELSE 0 END) PostbillCompFedTaxAdjAmt,
                        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')
                        THEN childpostbillajs.AJ_TAX_STATE
                        ELSE 0 END) PostbillCompStateTaxAdjAmt,
                        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')
                        THEN childpostbillajs.AJ_TAX_COUNTY
                        ELSE 0 END) PostbillCompCntyTaxAdjAmt,
                        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')
                        THEN childpostbillajs.AJ_TAX_LOCAL
                        ELSE 0 END) PostbillCompLocalTaxAdjAmt,
                        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')
                        THEN childpostbillajs.AJ_TAX_OTHER
                        ELSE 0 END) PostbillCompOtherTaxAdjAmt,
                        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')
                        THEN (childpostbillajs.AJ_TAX_FEDERAL + childpostbillajs.AJ_TAX_STATE + childpostbillajs.AJ_TAX_COUNTY
                        + childpostbillajs.AJ_TAX_LOCAL + childpostbillajs.AJ_TAX_OTHER)
                        ELSE 0 END) PostbillCompTotalTaxAdjAmt,
                        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NULL) THEN 0 ELSE 1 END) NumChildrenPostbillAdjusted,
                        SUM(CASE WHEN  (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status ='A')  THEN 1 ELSE 0 END)AS NumApprovedChildPostbillAdj
                        from
							t_adjustment_transaction childpostbillajs 
						where
							childpostbillajs.c_status IN ('A', 'P') AND childpostbillajs.n_adjustmenttype=1
                        group by id_parent_sess
                        )
                        ChildPostBillAdjustments on ChildPostBillAdjustments.id_parent_sess=au.id_sess
                        INNER JOIN t_acc_usage_interval taui on au.id_usage_interval = taui.id_usage_interval AND au.id_acc = taui.id_acc
                        LEFT OUTER JOIN t_acc_usage_interval ajaui on postbillajs.id_usage_interval = ajaui.id_usage_interval AND postbillajs.id_acc_payer = ajaui.id_acc
                        /*need to bring in adjustment type in order to set ManageAdjustments flag to false in case of REBILL adjustment type*/
                        LEFT OUTER JOIN t_adjustment_type prebillajtype on prebillajtype.id_prop = prebillajs.id_aj_type
                        LEFT OUTER JOIN t_adjustment_type postbillajtype on postbillajtype.id_prop = postbillajs.id_aj_type
      