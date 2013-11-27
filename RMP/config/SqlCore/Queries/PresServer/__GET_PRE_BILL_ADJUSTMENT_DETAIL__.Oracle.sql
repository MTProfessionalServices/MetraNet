
			SELECT 
			/* Query Tag: __GET_PRE_BILL_ADJUSTMENT_DETAIL__
			 CASE adj.n_adjustmenttype WHEN 0 THEN 'Prebill' ELSE 'Postbill' END AdjustmentType,	*/
			au.Amount UnadjustedAmount,
			adj.PrebillAdjAmt AdjustmentAmount,
			au.Amount + adj.PrebillAdjAmt AdjustedAmount,
			adj.id_reason_code ReasonCode,
			adj.AdjustmentTemplateDisplayName,
			adj.AdjustmentInstanceDisplayName,
			adj.ReasonCodeName,
			adj.ReasonCodeDescription,
			adj.ReasonCodeDisplayName,
			{fn IFNULL(adj.tx_desc, '')} Description
			FROM
			vw_adjustment_details adj
			INNER JOIN t_acc_usage au on adj.id_sess = au.id_sess
			
			WHERE
			adj.AdjustmentUsageInterval = %%ID_INTERVAL%%
			AND adj.id_acc_payer = %%ID_ACC%%
			/* CR 9739: only return prebill adjustments
			 IsPrebillADjusted flag doesn't really do it */
			AND n_adjustmenttype = 0
			
			/*TODO: pass lang code into query */
			AND adj.LanguageCode = 840
			 