
      INSERT INTO %%TABLE_NAME%%
      (id_adj_trx, id_sess, id_parent_sess, id_reason_code, id_acc_creator, id_acc_payer, c_status, n_adjustmenttype, dt_crt, dt_modified,
      id_aj_template, id_aj_instance, id_aj_type, id_usage_interval, AdjustmentAmount, 
      aj_tax_federal, aj_tax_state, aj_tax_county, aj_tax_local, aj_tax_other, am_currency, tx_desc, tx_default_desc, div_currency, div_amount)
      VALUES
      (
      %%ID_ADJUSTMENT%%,
      %%ID_SESS%%,
      %%ID_PARENT_SESS%%,
      %%ID_REASON_CODE%%,
      %%ID_ACC_CREATOR%%,
      %%ID_ACC_PAYER%%,
      /* Pending or Approved */
      '%%STATUS%%',
      %%ADJUSTMENT_TYPE%%,
       %%%SYSTEMDATE%%%,
       %%%SYSTEMDATE%%%,
      %%ID_AJ_TEMPLATE%%,
      %%ID_AJ_INSTANCE%%,
      %%ID_AJ_TYPE%%,
      %%ID_USAGE_INTERVAL%%,
      %%AMOUNT%%,
      %%AJ_TAX_FEDERAL%%,
      %%AJ_TAX_STATE%%,
      %%AJ_TAX_COUNTY%%,
      %%AJ_TAX_LOCAL%%,
      %%AJ_TAX_OTHER%%,
      N'%%CURRENCY%%',
      CASE WHEN (LENGTH('%%DESC%%') > 0) THEN N'%%DESC%%' ELSE NULL END,
      CASE WHEN (LENGTH('%%DEFAULTDESC%%') > 0) THEN N'%%DEFAULTDESC%%' ELSE NULL END,
      %%DIVISION_CURRENCY%%,
      %%DIVISION_AMOUNT%%
      )
			