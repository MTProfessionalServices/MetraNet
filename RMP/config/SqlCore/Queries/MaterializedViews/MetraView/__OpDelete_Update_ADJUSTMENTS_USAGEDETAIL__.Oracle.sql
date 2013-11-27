
declare rowcount6 int;
begin

delete from %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_adj_usagedetail;

Insert	into %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_adj_usagedetail
			(id_sess,id_usage_interval,am_currency,id_acc,c_status,
			CompoundPrebillAdjAmt,CompoundPrebillAdjedAmt,
			AtomicPrebillAdjAmt,AtomicPrebillAdjedAmt,
			CompoundPrebillFedTaxAdjAmt,CompoundPrebillStateTaxAdjAmt,
			CompoundPrebillCntyTaxAdjAmt,CompoundPrebillLocalTaxAdjAmt,
			CompoundPrebillOtherTaxAdjAmt,CompoundPrebillTotalTaxAdjAmt,
			AtomicPrebillFedTaxAdjAmt,AtomicPrebillStateTaxAdjAmt,
			AtomicPrebillCntyTaxAdjAmt,AtomicPrebillLocalTaxAdjAmt,
			AtomicPrebillOtherTaxAdjAmt,AtomicPrebillTotalTaxAdjAmt,
			CompoundPostbillFedTaxAdjAmt,CompoundPostbillStateTaxAdjAmt,
			CompoundPostbillCntyTaxAdjAmt,CompoundPostbillLocalTaxAdjAmt,
			CompoundPostbillOtherTaxAdjAmt,CompoundPostbillTotalTaxAdjAmt,
			AtomicPostbillFedTaxAdjAmt,AtomicPostbillStateTaxAdjAmt,
			AtomicPostbillCntyTaxAdjAmt,AtomicPostbillLocalTaxAdjAmt,
			AtomicPostbillOtherTaxAdjAmt,AtomicPostbillTotalTaxAdjAmt,
			CompoundPostbillAdjAmt,CompoundPostbillAdjedAmt,AtomicPostbillAdjAmt,
			AtomicPostbillAdjedAmt,
			PrebillAdjustmentID,PostbillAdjustmentID,
			IsAdjusted,IsPrebillAdjusted,IsPostbillAdjusted,IsPrebillTransaction,
			CanAdjust,CanRebill,
			CanManageAdjustments,
			IsIntervalSoftClosed,
			NumTransactions
			)
			select 
			au.id_sess,
			au.id_usage_interval,
			au.am_currency,
			au.id_acc,
			nvl(prebillajs.c_status,postbillajs.c_status) c_status,
			sum(CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
				THEN prebillajs.AdjustmentAmount
				ELSE 0 END
				+ 
				{fn IFNULL(ChildPreBillAdjustments.PrebillCompoundAdjAmt, 0.0)}) AS CompoundPrebillAdjAmt,
			sum((au.amount + CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
				THEN prebillajs.AdjustmentAmount
				ELSE 0 END + {fn IFNULL(ChildPreBillAdjustments.PrebillCompoundAdjAmt, 0.0)})) AS CompoundPrebillAdjedAmt,
			sum((CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
					THEN prebillajs.AdjustmentAmount
					ELSE 0 END)) AS AtomicPrebillAdjAmt,
			sum((au.amount + (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
					THEN prebillajs.AdjustmentAmount
					ELSE 0 END) )) AS AtomicPrebillAdjedAmt,
			sum(CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
				THEN prebillajs.aj_tax_federal
				ELSE 0 END
				+ 
				{fn IFNULL(ChildPreBillAdjustments.PrebillCompoundFedTaxAdjAmt, 0.0)}) AS CompoundPrebillFedTaxAdjAmt,
			sum(CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
				THEN prebillajs.aj_tax_state
				ELSE 0 END
				+ 
				{fn IFNULL(ChildPreBillAdjustments.PrebillCompoundStateTaxAdjAmt, 0.0)}) AS PrebillCompoundStateTaxAdjAmt,            
			sum(CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
				THEN prebillajs.aj_tax_county
				ELSE 0 END
				+ 
				{fn IFNULL(ChildPreBillAdjustments.PrebillCompoundCntyTaxAdjAmt, 0.0)}) AS CompoundPrebillCntyTaxAdjAmt,
			sum(CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
				THEN prebillajs.aj_tax_local
				ELSE 0 END
				+ 
				{fn IFNULL(ChildPreBillAdjustments.PrebillCompoundLocalTaxAdjAmt, 0.0)}) AS CompoundPrebillLocalTaxAdjAmt,            
			sum(CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
				THEN prebillajs.aj_tax_other
				ELSE 0 END
				+ 
				{fn IFNULL(ChildPreBillAdjustments.PrebillCompoundOtherTaxAdjAmt, 0.0)}) AS CompoundPrebillOtherTaxAdjAmt,            
			sum(CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
				THEN (prebillajs.aj_tax_federal + prebillajs.aj_tax_state + prebillajs.aj_tax_county + prebillajs.aj_tax_local + prebillajs.aj_tax_other)
				ELSE 0 END
				+ 
				{fn IFNULL(ChildPreBillAdjustments.PrebillCompoundTotalTaxAdjAmt, 0.0)}) AS CompoundPrebillTotalTaxAdjAmt,					
			sum((CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
				THEN prebillajs.aj_tax_federal
				ELSE 0 END)) AS AtomicPrebillFedTaxAdjAmt,            
			sum((CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
				THEN prebillajs.aj_tax_state
				ELSE 0 END)) AS AtomicPrebillStateTaxAdjAmt,        
			sum((CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
				THEN prebillajs.aj_tax_county
				ELSE 0 END)) AS AtomicPrebillCntyTaxAdjAmt,
			sum((CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
				THEN prebillajs.aj_tax_local
				ELSE 0 END)) AS AtomicPrebillLocalTaxAdjAmt,
			sum((CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
				THEN prebillajs.aj_tax_other
				ELSE 0 END)) AS AtomicPrebillOtherTaxAdjAmt,            
			sum((CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
				THEN (prebillajs.aj_tax_federal + prebillajs.aj_tax_state + prebillajs.aj_tax_county + prebillajs.aj_tax_local + prebillajs.aj_tax_other)
				ELSE 0 END)) AS AtomicPrebillTotalTaxAdjAmt,        			
			sum(CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A' and postbillajs.n_adjustmenttype = 1)	
				THEN prebillajs.aj_tax_federal
				ELSE 0 END
				+ 
				{fn IFNULL(ChildPostBillAdjustments.PostbillCompoundFedTaxAdjAmt, 0.0)}) AS CompoundPostbillFedTaxAdjAmt,            
			sum(CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 1)	
				THEN postbillajs.aj_tax_state
				ELSE 0 END
				+ 
				{fn IFNULL(ChildPostBillAdjustments.PostbillCompoundStateTaxAdjAmt, 0.0)}) AS CompoundPostbillStateTaxAdjAmt,            
			sum(CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A' and postbillajs.n_adjustmenttype = 1)	
				THEN postbillajs.aj_tax_county
				ELSE 0 END
				+ 
				{fn IFNULL(ChildPostBillAdjustments.PostbillCompoundCntyTaxAdjAmt, 0.0)}) AS CompoundPostbillCntyTaxAdjAmt,            
			sum(CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A' and postbillajs.n_adjustmenttype = 1)	
				THEN postbillajs.aj_tax_local
				ELSE 0 END
				+ 
				{fn IFNULL(ChildPostBillAdjustments.PostbillCompoundLocalTaxAdjAmt, 0.0)}) AS CompoundPostbillLocalTaxAdjAmt,            
			sum(CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A' and postbillajs.n_adjustmenttype = 1)	
				THEN postbillajs.aj_tax_other
				ELSE 0 END
				+ 
				{fn IFNULL(ChildPostBillAdjustments.PostbillCompoundOtherTaxAdjAmt, 0.0)}) AS CompoundPostbillOtherTaxAdjAmt,
	            
			sum(CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A' and postbillajs.n_adjustmenttype = 1)	
				THEN (postbillajs.aj_tax_federal + postbillajs.aj_tax_state + 
										postbillajs.aj_tax_county + postbillajs.aj_tax_local + postbillajs.aj_tax_other)
				ELSE 0 END
				+ 
				{fn IFNULL(ChildPostBillAdjustments.PostbillCompoundTotalTaxAdjAmt, 0.0)}) AS CompoundPostbillTotalTaxAdjAmt,            
					
			sum((CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A' and postbillajs.n_adjustmenttype = 1)	
				THEN prebillajs.aj_tax_federal
				ELSE 0 END)) AS AtomicPostbillFedTaxAdjAmt,
	            
			sum((CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A' and postbillajs.n_adjustmenttype = 1)	
				THEN postbillajs.aj_tax_state
				ELSE 0 END)) AS AtomicPostbillStateTaxAdjAmt,        
			sum((CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A' and postbillajs.n_adjustmenttype = 1)	
				THEN postbillajs.aj_tax_county
				ELSE 0 END)) AS AtomicPostbillCntyTaxAdjAmt,        
			sum((CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A' and postbillajs.n_adjustmenttype = 1)	
				THEN postbillajs.aj_tax_local
				ELSE 0 END)) AS AtomicPostbillLocalTaxAdjAmt,            
			sum((CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A' and postbillajs.n_adjustmenttype = 1)	
				THEN postbillajs.aj_tax_other
				ELSE 0 END)) AS AtomicPostbillOtherTaxAdjAmt,            
			sum((CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A' and postbillajs.n_adjustmenttype = 1)	
				THEN (postbillajs.aj_tax_federal + postbillajs.aj_tax_state + postbillajs.aj_tax_county +
										postbillajs.aj_tax_local + postbillajs.aj_tax_other)
				ELSE 0 END)) AS AtomicPostbillTotalTaxAdjAmt,
			sum(CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A' and postbillajs.n_adjustmenttype = 1)	
				THEN postbillajs.AdjustmentAmount
				ELSE 0 END + {fn IFNULL(ChildPostBillAdjustments.PostbillCompoundAdjAmt, 0.0)}) AS CompoundPostbillAdjAmt,
			
			sum((au.amount + CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A' and postbillajs.n_adjustmenttype = 1)	
				THEN postbillajs.AdjustmentAmount
				ELSE 0 END  + {fn IFNULL(ChildPostBillAdjustments.PostbillCompoundAdjAmt, 0.0)} 
			+ 
			CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
				THEN prebillajs.AdjustmentAmount
				ELSE 0 END
				+ 
				{fn IFNULL(ChildPreBillAdjustments.PrebillCompoundAdjAmt, 0.0)}
			)) 
				AS CompoundPostbillAdjedAmt,
			sum((CASE WHEN (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status = 'A' and postbillajs.n_adjustmenttype = 1)	
					THEN postbillajs.AdjustmentAmount
					ELSE 0 END)) AS AtomicPostbillAdjAmt, 
			sum((au.amount + (CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A' and postbillajs.n_adjustmenttype = 1)	
					THEN postbillajs.AdjustmentAmount
					ELSE 0 END) 			
			+
			(CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
					THEN prebillajs.AdjustmentAmount
					ELSE 0 END)
					)) AS AtomicPostbillAdjedAmt,
			sum((CASE WHEN prebillajs.id_adj_trx IS not NULL and prebillajs.n_adjustmenttype = 0 THEN prebillajs.id_adj_trx else -1 END)) AS PrebillAdjustmentID,
			sum((CASE WHEN postbillajs.id_adj_trx IS not NULL and postbillajs.n_adjustmenttype = 1 THEN postbillajs.id_adj_trx else -1 END)) AS PostbillAdjustmentID,			
		        max(CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status in ('A','P'))
			OR (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status in ('A','P'))
		            THEN 'Y' ELSE 'N' END) AS IsAdjusted,
			max((CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
					THEN 'Y' ELSE 'N' END)) AS IsPrebillAdjusted,
			max((CASE WHEN (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status = 'A' and postbillajs.n_adjustmenttype = 1)	
					THEN 'Y' ELSE 'N' END)) AS IsPostbillAdjusted,
			max((CASE WHEN taui.tx_status in ('O')	
					THEN 'Y' 
					ELSE 'N' END)) AS IsPrebillTransaction,
			max((CASE WHEN	
			(taui.tx_status in	('C')) OR
			(taui.tx_status =	'O' AND prebillajs.id_adj_trx IS NOT NULL) OR
			(taui.tx_status =	'H' AND postbillajs.id_adj_trx IS NOT NULL)
				then 'N'  else 'Y' end)) AS CanAdjust,
			max((CASE WHEN	
			(au.id_parent_sess IS NOT NULL) 
				OR
			(taui.tx_status =	('C')) 
			OR
			(taui.tx_status =	'O' AND (prebillajs.id_adj_trx IS NOT NULL 
			OR (ChildPreBillAdjustments.NumChildrenPrebillAdjusted IS NOT NULL AND ChildPreBillAdjustments.NumChildrenPrebillAdjusted > 0)) )
			OR
			(taui.tx_status =	'H' AND (prebillajs.id_adj_trx IS NOT NULL 
			OR (ChildPostBillAdjustments.NumChildrenPostbillAdjusted IS NOT NULL AND ChildPostBillAdjustments.NumChildrenPostbillAdjusted > 0)))
			then 'N' else 'Y' end))	AS CanRebill,
			max((CASE WHEN (postbillajs.id_adj_trx IS NOT NULL and postbillajs.n_adjustmenttype = 1) THEN
			(CASE WHEN (ajaui.tx_status in ('C', 'H') OR
			postbillajtype.n_adjustmenttype = 4) then 'N'  else 'Y' end)
			ELSE 
			(CASE WHEN (prebillajs.id_adj_trx IS NOT NULL and prebillajs.n_adjustmenttype = 0) THEN
			(CASE WHEN taui.tx_status in ('C', 'H') then 'N'  else 'Y' end)
			ELSE 'N' END)
			END))
			AS CanManageAdjustments,
			max((CASE WHEN (taui.tx_status =	'C' ) THEN 'Y' ELSE 'N' END)) As IsIntervalSoftClosed,
			COUNT(*) NumTransactions
			from
			t_acc_usage au 
			left outer join %%DELTA_DELETE_T_ADJUSTMENT_TRANSACTION%% prebillajs on prebillajs.id_sess=au.id_sess 
			AND prebillajs.c_status IN ('A', 'P') AND prebillajs.n_adjustmenttype = 0
			left outer join %%DELTA_DELETE_T_ADJUSTMENT_TRANSACTION%% postbillajs on postbillajs.id_sess=au.id_sess 
			AND postbillajs.c_status IN ('A', 'P') AND postbillajs.n_adjustmenttype = 1
			left outer join
			(
			select id_parent_sess, 
			SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A' and childprebillajs.n_adjustmenttype = 0)	
				THEN childprebillajs.AdjustmentAmount
				ELSE 0 END) PrebillCompoundAdjAmt, 
			SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A' and childprebillajs.n_adjustmenttype = 0)	
				THEN childprebillajs.AJ_TAX_FEDERAL
				ELSE 0 END) PrebillCompoundFedTaxAdjAmt, 
			SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A' and childprebillajs.n_adjustmenttype = 0)	
				THEN childprebillajs.AJ_TAX_STATE
				ELSE 0 END) PrebillCompoundStateTaxAdjAmt, 
			SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A' and childprebillajs.n_adjustmenttype = 0)	
				THEN childprebillajs.AJ_TAX_COUNTY
				ELSE 0 END) PrebillCompoundCntyTaxAdjAmt, 
			SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A' and childprebillajs.n_adjustmenttype = 0)	
				THEN childprebillajs.AJ_TAX_LOCAL
				ELSE 0 END) PrebillCompoundLocalTaxAdjAmt,       
			SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A' and childprebillajs.n_adjustmenttype = 0)	
				THEN childprebillajs.AJ_TAX_OTHER
				ELSE 0 END) PrebillCompoundOtherTaxAdjAmt, 
			SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A' and childprebillajs.n_adjustmenttype = 0)	
				THEN (childprebillajs.AJ_TAX_FEDERAL + childprebillajs.AJ_TAX_STATE + childprebillajs.AJ_TAX_COUNTY
				+ childprebillajs.AJ_TAX_LOCAL + childprebillajs.AJ_TAX_OTHER)
				ELSE 0 END) PrebillCompoundTotalTaxAdjAmt, 
			SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NULL and childprebillajs.n_adjustmenttype = 0) THEN 0 ELSE 1 END) NumChildrenPrebillAdjusted,
			SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status ='A' and childprebillajs.n_adjustmenttype = 0) THEN 1 ELSE 0 END) NumApprovedChildPrebillAdjed
			from
			%%DELTA_DELETE_T_ADJUSTMENT_TRANSACTION%% childprebillajs 
			where childprebillajs.c_status IN ('A', 'P') AND childprebillajs.n_adjustmenttype =0
			group by id_parent_sess
			) 
			ChildPreBillAdjustments on ChildPreBillAdjustments.id_parent_sess=au.id_sess 
			left outer join
			(
			select id_parent_sess, 
			SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A' and childpostbillajs.n_adjustmenttype = 1)	
				THEN childpostbillajs.AdjustmentAmount
				ELSE 0 END) PostbillCompoundAdjAmt,
			SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A' and childpostbillajs.n_adjustmenttype = 1)	
				THEN childpostbillajs.AJ_TAX_FEDERAL
				ELSE 0 END) PostbillCompoundFedTaxAdjAmt,	      
			SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A' and childpostbillajs.n_adjustmenttype = 1)	
				THEN childpostbillajs.AJ_TAX_STATE
				ELSE 0 END) PostbillCompoundStateTaxAdjAmt,	      
			SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A' and childpostbillajs.n_adjustmenttype = 1)	
				THEN childpostbillajs.AJ_TAX_COUNTY
				ELSE 0 END) PostbillCompoundCntyTaxAdjAmt,	        
			SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A' and childpostbillajs.n_adjustmenttype = 1)	
				THEN childpostbillajs.AJ_TAX_LOCAL
				ELSE 0 END) PostbillCompoundLocalTaxAdjAmt,	        
			SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A' and childpostbillajs.n_adjustmenttype = 1)	
				THEN childpostbillajs.AJ_TAX_OTHER
				ELSE 0 END) PostbillCompoundOtherTaxAdjAmt,
			SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A' and childpostbillajs.n_adjustmenttype = 1)	
				THEN (childpostbillajs.AJ_TAX_FEDERAL + childpostbillajs.AJ_TAX_STATE + childpostbillajs.AJ_TAX_COUNTY
				+ childpostbillajs.AJ_TAX_LOCAL + childpostbillajs.AJ_TAX_OTHER)
				ELSE 0 END) PostbillCompoundTotalTaxAdjAmt,
			SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NULL and childpostbillajs.n_adjustmenttype = 1) THEN 0 ELSE 1 END) NumChildrenPostbillAdjusted,
			SUM(CASE WHEN  (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status ='A' and childpostbillajs.n_adjustmenttype = 1)  THEN 1 ELSE 0 END)AS NumApprovedChildPostbillAdjed
			from
			%%DELTA_DELETE_T_ADJUSTMENT_TRANSACTION%% childpostbillajs 
			where childpostbillajs.c_status IN ('A', 'P') AND childpostbillajs.n_adjustmenttype =1
			group by id_parent_sess
			) 
			ChildPostBillAdjustments on ChildPostBillAdjustments.id_parent_sess=au.id_sess 
      INNER JOIN t_acc_usage_interval taui on au.id_usage_interval = taui.id_usage_interval AND au.id_acc = taui.id_acc
      LEFT OUTER JOIN t_acc_usage_interval ajaui on postbillajs.id_usage_interval = ajaui.id_usage_interval AND postbillajs.id_acc_payer = ajaui.id_acc
			LEFT OUTER JOIN t_adjustment_type prebillajtype on prebillajtype.id_prop = prebillajs.id_aj_type 
			LEFT OUTER JOIN t_adjustment_type postbillajtype on postbillajtype.id_prop = postbillajs.id_aj_type 
			where  
			exists ( select 1 from %%DELTA_DELETE_T_ADJUSTMENT_TRANSACTION%%
						where %%DELTA_DELETE_T_ADJUSTMENT_TRANSACTION%%.id_sess = au.id_sess
						and %%DELTA_DELETE_T_ADJUSTMENT_TRANSACTION%%.n_adjustmenttype in (0,1)
						and c_status in ('A','P')
					)
group by
			au.id_sess,
			au.id_usage_interval,
			au.am_currency,
			au.id_acc,
			nvl(prebillajs.c_status,postbillajs.c_status);

insert into %%DELTA_DELETE_ADJUSTMENTS_USAGEDETAIL%%  
			(id_sess,id_usage_interval,am_currency,id_acc,c_status,
			CompoundPostbillFedTaxAdjAmt,CompoundPostbillStateTaxAdjAmt,
			CompoundPostbillCntyTaxAdjAmt,CompoundPostbillLocalTaxAdjAmt,
			CompoundPostbillOtherTaxAdjAmt,CompoundPostbillTotalTaxAdjAmt,
			AtomicPostbillFedTaxAdjAmt,AtomicPostbillStateTaxAdjAmt,
			AtomicPostbillCntyTaxAdjAmt,AtomicPostbillLocalTaxAdjAmt,
			AtomicPostbillOtherTaxAdjAmt,AtomicPostbillTotalTaxAdjAmt,
			CompoundPostbillAdjAmt,CompoundPostbillAdjedAmt,AtomicPostbillAdjAmt,
			AtomicPostbillAdjedAmt,
			PostbillAdjustmentID,
			IsAdjusted,IsPostbillAdjusted,
			CanAdjust,CanRebill,
			CanManageAdjustments,
			IsIntervalSoftClosed,NumTransactions
			)
			select 
			dm_1.id_sess,dm_1.id_usage_interval,dm_1.am_currency,dm_1.id_acc,dm_1.c_status,
			dm_1.CompoundPostbillFedTaxAdjAmt,dm_1.CompoundPostbillStateTaxAdjAmt,
			dm_1.CompoundPostbillCntyTaxAdjAmt,dm_1.CompoundPostbillLocalTaxAdjAmt,
			dm_1.CompoundPostbillOtherTaxAdjAmt,dm_1.CompoundPostbillTotalTaxAdjAmt,
			dm_1.AtomicPostbillFedTaxAdjAmt,dm_1.AtomicPostbillStateTaxAdjAmt,
			dm_1.AtomicPostbillCntyTaxAdjAmt,dm_1.AtomicPostbillLocalTaxAdjAmt,
			dm_1.AtomicPostbillOtherTaxAdjAmt,dm_1.AtomicPostbillTotalTaxAdjAmt,
			dm_1.CompoundPostbillAdjAmt,dm_1.CompoundPostbillAdjedAmt,
			dm_1.AtomicPostbillAdjAmt,dm_1.AtomicPostbillAdjedAmt,
			dm_1.PostbillAdjustmentID,dm_1.IsAdjusted,dm_1.IsPostbillAdjusted,
			dm_1.CanAdjust,dm_1.CanRebill,dm_1.CanManageAdjustments,dm_1.IsIntervalSoftClosed,
			dm_1.NumTransactions
from %%ADJUSTMENTS_USAGEDETAIL%% dm_1 
inner join  %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_adj_usagedetail tmp2 on
			dm_1.id_sess=tmp2.id_sess 
      and dm_1.id_usage_interval=tmp2.id_usage_interval 
      and dm_1.am_currency=tmp2.am_currency 
      and dm_1.id_acc=tmp2.id_acc
      and dm_1.c_status=tmp2.c_status;
rowcount6 := sql%rowcount;

if (rowcount6 > 0)
then
update %%ADJUSTMENTS_USAGEDETAIL%% dm_1 set
      (CompoundPostbillFedTaxAdjAmt,CompoundPostbillStateTaxAdjAmt,CompoundPostbillCntyTaxAdjAmt,
       CompoundPostbillLocalTaxAdjAmt,CompoundPostbillOtherTaxAdjAmt,CompoundPostbillTotalTaxAdjAmt,
       AtomicPostbillFedTaxAdjAmt,AtomicPostbillStateTaxAdjAmt,AtomicPostbillCntyTaxAdjAmt,
       AtomicPostbillLocalTaxAdjAmt,AtomicPostbillOtherTaxAdjAmt,AtomicPostbillTotalTaxAdjAmt,
       CompoundPostbillAdjAmt,CompoundPostbillAdjedAmt,AtomicPostbillAdjAmt,AtomicPostbillAdjedAmt,
       PostbillAdjustmentID,IsAdjusted,IsPostbillAdjusted,IsPrebillTransaction,CanAdjust,
       CanRebill,CanManageAdjustments,IsIntervalSoftClosed,NumTransactions)
       = (select nvl(tmp2.CompoundPostbillFedTaxAdjAmt, 0.0), 
      nvl(tmp2.CompoundPostbillStateTaxAdjAmt, 0.0), 
      nvl(tmp2.CompoundPostbillCntyTaxAdjAmt, 0.0), 
      nvl(tmp2.CompoundPostbillLocalTaxAdjAmt, 0.0), 
      nvl(tmp2.CompoundPostbillOtherTaxAdjAmt, 0.0), 
      nvl(tmp2.CompoundPostbillTotalTaxAdjAmt, 0.0), 
      nvl(tmp2.AtomicPostbillFedTaxAdjAmt, 0.0), 
      nvl(tmp2.AtomicPostbillStateTaxAdjAmt, 0.0), 
      nvl(tmp2.AtomicPostbillCntyTaxAdjAmt, 0.0), 
      nvl(tmp2.AtomicPostbillLocalTaxAdjAmt, 0.0), 
      nvl(tmp2.AtomicPostbillOtherTaxAdjAmt, 0.0), 
      nvl(tmp2.AtomicPostbillTotalTaxAdjAmt, 0.0), 
      nvl(tmp2.CompoundPostbillAdjAmt, 0.0), 
      nvl(tmp2.CompoundPostbillAdjedAmt, 0.0) - nvl(dm_1.CompoundPrebillAdjAmt,0.0), 
      nvl(tmp2.AtomicPostbillAdjAmt, 0.0), 
      nvl(tmp2.AtomicPostbillAdjedAmt, 0.0) - nvl(dm_1.AtomicPrebillAdjAmt,0.0), 
      (CASE WHEN tmp2.PostbillAdjustmentID != -1 THEN tmp2.PostbillAdjustmentID else dm_1.PostbillAdjustmentID END),
      tmp2.IsAdjusted,
      (CASE WHEN tmp2.IsPostbillAdjusted ='Y' or dm_1.IsPostbillAdjusted ='Y' THEN 'Y' else 'N' END),
      (CASE WHEN tmp2.IsPrebillTransaction ='Y' or dm_1.IsPrebillTransaction ='Y' THEN 'Y' else 'N' END),
      tmp2.CanAdjust,
      tmp2.CanRebill,
      tmp2.CanManageAdjustments,
      tmp2.IsIntervalSoftClosed,
      nvl(dm_1.NumTransactions,0) - nvl(tmp2.NumTransactions,0)
			from %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_adj_usagedetail tmp2 where
			dm_1.id_sess=tmp2.id_sess 
      and dm_1.id_usage_interval=tmp2.id_usage_interval 
      and dm_1.am_currency=tmp2.am_currency 
      and dm_1.id_acc=tmp2.id_acc
      and dm_1.c_status=tmp2.c_status)
  where exists (select 1 
	from %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_adj_usagedetail tmp2 where
					dm_1.id_sess=tmp2.id_sess 
      and dm_1.id_usage_interval=tmp2.id_usage_interval 
      and dm_1.am_currency=tmp2.am_currency 
      and dm_1.id_acc=tmp2.id_acc
      and dm_1.c_status=tmp2.c_status);

delete from %%ADJUSTMENTS_USAGEDETAIL%% where (NumTransactions <= 0 or c_status is null);

insert into %%DELTA_INSERT_ADJUSTMENTS_USAGEDETAIL%%  
			(id_sess,id_usage_interval,am_currency,id_acc,c_status,
			CompoundPostbillFedTaxAdjAmt,CompoundPostbillStateTaxAdjAmt,
			CompoundPostbillCntyTaxAdjAmt,CompoundPostbillLocalTaxAdjAmt,
			CompoundPostbillOtherTaxAdjAmt,CompoundPostbillTotalTaxAdjAmt,
			AtomicPostbillFedTaxAdjAmt,AtomicPostbillStateTaxAdjAmt,
			AtomicPostbillCntyTaxAdjAmt,AtomicPostbillLocalTaxAdjAmt,
			AtomicPostbillOtherTaxAdjAmt,AtomicPostbillTotalTaxAdjAmt,
			CompoundPostbillAdjAmt,CompoundPostbillAdjedAmt,AtomicPostbillAdjAmt,
			AtomicPostbillAdjedAmt,
			PostbillAdjustmentID,
			IsAdjusted,IsPostbillAdjusted,
			CanAdjust,CanRebill,
			CanManageAdjustments,
			IsIntervalSoftClosed,NumTransactions
			)
			select 
			dm_1.id_sess,dm_1.id_usage_interval,dm_1.am_currency,dm_1.id_acc,dm_1.c_status,
			dm_1.CompoundPostbillFedTaxAdjAmt,dm_1.CompoundPostbillStateTaxAdjAmt,
			dm_1.CompoundPostbillCntyTaxAdjAmt,dm_1.CompoundPostbillLocalTaxAdjAmt,
			dm_1.CompoundPostbillOtherTaxAdjAmt,dm_1.CompoundPostbillTotalTaxAdjAmt,
			dm_1.AtomicPostbillFedTaxAdjAmt,dm_1.AtomicPostbillStateTaxAdjAmt,
			dm_1.AtomicPostbillCntyTaxAdjAmt,dm_1.AtomicPostbillLocalTaxAdjAmt,
			dm_1.AtomicPostbillOtherTaxAdjAmt,dm_1.AtomicPostbillTotalTaxAdjAmt,
			dm_1.CompoundPostbillAdjAmt,dm_1.CompoundPostbillAdjedAmt,
			dm_1.AtomicPostbillAdjAmt,dm_1.AtomicPostbillAdjedAmt,
			dm_1.PostbillAdjustmentID,dm_1.IsAdjusted,dm_1.IsPostbillAdjusted,
			dm_1.CanAdjust,dm_1.CanRebill,dm_1.CanManageAdjustments,dm_1.IsIntervalSoftClosed,dm_1.NumTransactions
			from %%ADJUSTMENTS_USAGEDETAIL%% dm_1 
			inner join  %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_adj_usagedetail tmp2 on
					dm_1.id_sess=tmp2.id_sess 
      and dm_1.id_usage_interval=tmp2.id_usage_interval 
      and dm_1.am_currency=tmp2.am_currency 
      and dm_1.id_acc=tmp2.id_acc
      and dm_1.c_status=tmp2.c_status;
end if;

end;
			