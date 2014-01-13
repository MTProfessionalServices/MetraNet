
    /* __UPDATE_CALC_FORMULA_BY_ADJUSMENT_TYPE_ID__ */
      UPDATE t_calc_formula SET
      tx_formula = N'%%TX_TEXT%%',
      id_engine = %%ID_ENGINE%%
      WHERE id_formula = 
      (SELECT id_formula FROM t_adjustment_type WHERE
      id_prop = %%ID_AJ_TYPE%%)
  