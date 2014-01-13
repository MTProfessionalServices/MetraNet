
			SELECT
			/* __GET_AJ_TRANSACTION_INFO__ */
			tau.*,
			ajt.id_aj_template,
			ajt.id_aj_instance,
			ajt.id_aj_type,
      pi.id_pi PITypeID,
			(CASE  WHEN  (ajt.n_adjustmenttype IS NULL) THEN 'N' ELSE 'Y' END) AS  IsAdjusted ,
      (CASE WHEN ( ajt.n_adjustmenttype IS NOT  NULL AND ajt.n_adjustmenttype=0 ) THEN 'Y'  ELSE 'N' END)  AS IsPrebillAdjusted,
      (CASE WHEN ( ajt.n_adjustmenttype IS NOT  NULL AND ajt.n_adjustmenttype=1 ) THEN 'Y'  ELSE 'N' END)  AS IsPostbillAdjusted,
      case when (taui.tx_status = 'O') then 'Y' else 'N' end as IsPreBill
      from t_acc_usage tau
      LEFT OUTER JOIN t_adjustment_transaction ajt on ajt.id_sess = tau.id_sess
      INNER JOIN t_acc_usage_interval taui on taui.id_usage_interval = tau.id_usage_interval AND tau.id_acc = taui.id_acc
      INNER JOIN t_pi_template pi on tau.id_pi_template = pi.id_template
      WHERE ajt.id_adj_trx = %%ID_TRX%%
		