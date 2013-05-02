
     UPDATE t_adjustment_type SET
      n_AdjustmentType = %%UOM%%,
      b_SupportBulk = '%%SUPPORTS_BULK%%',
      tx_default_desc = CASE WHEN (LENGTH(N'%%DEFAULT_DESC%%') > 0) THEN N'%%DEFAULT_DESC%%'
      ELSE NULL END 
      WHERE id_prop = %%ID_PROP%%
  