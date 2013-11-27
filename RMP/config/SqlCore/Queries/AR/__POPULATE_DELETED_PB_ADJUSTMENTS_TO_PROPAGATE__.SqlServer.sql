
    if object_id('tmp_PBAdjustments') is not null
      drop table tmp_PBAdjustments;        

    SELECT TOP %%SET_SIZE%%
      adj.id_adj_trx as ID,
      CASE WHEN (adj.AdjustmentAmount+adj.aj_tax_federal+adj.aj_tax_state+adj.aj_tax_county+adj.aj_tax_local+adj.aj_tax_other) < 0 THEN 'Credit' ELSE 'Debit' END as DelType,
      ARBatchID as DelBatchID,
      CASE WHEN (adj.AdjustmentAmount+adj.aj_tax_federal+adj.aj_tax_state+adj.aj_tax_county+adj.aj_tax_local+adj.aj_tax_other) >= 0 THEN 'Credit' ELSE 'Debit' END as CompensateType,
      '%%DEF_BATCH_ID%%' as CompensateBatchID,
      '%%DESCRIPTION_PREFIX%%' + '%%ID_PREFIX%%' + CONVERT(varchar, adj.id_adj_trx) as Description,
      %%%SYSTEMDATE%%% as AdjustmentDate,
      am.ExtAccount as ExtAccountID,
      --CASE WHEN adj.AdjustmentAmount < 0 THEN -adj.AdjustmentAmount ELSE adj.AdjustmentAmount END as Amount,
      ABS(adj.AdjustmentAmount+adj.aj_tax_federal+adj.aj_tax_state+adj.aj_tax_county+adj.aj_tax_local+adj.aj_tax_other) as Amount,
     au.am_currency as Currency,
      ' ' as ARDelAction
    INTO tmp_PBAdjustments
    FROM t_adjustment_transaction adj
      JOIN t_acc_usage au ON adj.id_sess = au.id_sess
      INNER JOIN vw_ar_acc_mapper am ON am.id_acc = adj.id_acc_payer and am.ExtNamespace = '%%ACC_NAME_SPACE%%'
    WHERE ARBatchID IS NOT NULL
      AND ARDelBatchID IS NULL
      AND adj.c_status = 'D'
      AND n_adjustmenttype = 1
        