
      begin

			Delete from %%ADJUSTMENTS_USAGEDETAIL%% where id_usage_interval not in 
			(select id_interval from t_archive where status = 'A' and tt_end = dbo.mtmaxdate());

			insert into %%ADJUSTMENTS_USAGEDETAIL%% 
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
				{fn IFNULL(ChildPreBillAdjustments.PrebillCompoundStateTaxAdjAmt, 0.0)}) AS CompoundPrebillStateTaxAdjAmt,            
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
			max((CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status = 'A')
					THEN 'Y' ELSE 'N' END)) AS IsAdjusted,
			max((CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status = 'A' and prebillajs.n_adjustmenttype = 0)	
					THEN 'Y' ELSE 'N' END)) AS IsPrebillAdjusted,
			max((CASE WHEN (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status = 'A' and postbillajs.n_adjustmenttype = 1)	
					THEN 'Y' ELSE 'N' END)) AS IsPostbillAdjusted,
			max((CASE WHEN taui.tx_status in ('O')	
					THEN 'Y' 
					ELSE 'N' END)) AS IsPreBill,
			max((CASE WHEN	
			(taui.tx_status in	('C')) OR
			(taui.tx_status =	'O' AND prebillajs.id_adj_trx IS NOT NULL) OR
			(taui.tx_status =	'H' AND prebillajs.id_adj_trx IS NOT NULL)
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
			left outer join T_ADJUSTMENT_TRANSACTION prebillajs on prebillajs.id_sess=au.id_sess 
			AND prebillajs.c_status IN ('A', 'P') AND prebillajs.n_adjustmenttype = 0
			left outer join T_ADJUSTMENT_TRANSACTION postbillajs on postbillajs.id_sess=au.id_sess 
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
			SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status ='A' and childprebillajs.n_adjustmenttype = 0) THEN 1 ELSE 0 END) NumApprovedChildPrebillAdj
			from
			T_ADJUSTMENT_TRANSACTION childprebillajs 
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
			SUM(CASE WHEN  (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status ='A' and childpostbillajs.n_adjustmenttype = 1)  THEN 1 ELSE 0 END)AS NumApprovedChildPostbillAdj
			from
			T_ADJUSTMENT_TRANSACTION childpostbillajs
			where childpostbillajs.c_status IN ('A', 'P') AND childpostbillajs.n_adjustmenttype =1
			group by id_parent_sess
			) 
			ChildPostBillAdjustments on ChildPostBillAdjustments.id_parent_sess=au.id_sess 
      INNER JOIN t_acc_usage_interval taui on au.id_usage_interval = taui.id_usage_interval AND au.id_acc = taui.id_acc
      LEFT OUTER JOIN t_acc_usage_interval ajaui on postbillajs.id_usage_interval = ajaui.id_usage_interval AND postbillajs.id_acc_payer = ajaui.id_acc
			LEFT OUTER JOIN t_adjustment_type prebillajtype on prebillajtype.id_prop = prebillajs.id_aj_type 
			LEFT OUTER JOIN t_adjustment_type postbillajtype on postbillajtype.id_prop = postbillajs.id_aj_type 
			where  
			exists ( select 1 from T_ADJUSTMENT_TRANSACTION
						where T_ADJUSTMENT_TRANSACTION.id_sess = au.id_sess
						and T_ADJUSTMENT_TRANSACTION.n_adjustmenttype in (0,1)
						and c_status in ('A','P')
					)
		group by
			au.id_sess,
			au.id_usage_interval,
			au.am_currency,
			au.id_acc,
			nvl(prebillajs.c_status,postbillajs.c_status);

			end;
			