
    /* __UPDATE_CALC_FORMULA__ */
      UPDATE t_calc_formula SET
      tx_formula = @TX_TEXT,
      id_engine = @ID_ENGINE
      WHERE id_formula = @ID_FORMULA
  