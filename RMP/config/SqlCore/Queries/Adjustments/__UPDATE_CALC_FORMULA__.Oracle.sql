
    /* __UPDATE_CALC_FORMULA__ */
    DECLARE
    v_long_text CLOB;
	BEGIN
		v_long_text:=:TX_TEXT;
      UPDATE t_calc_formula SET
      tx_formula = v_long_text,
      id_engine = :ID_ENGINE
      WHERE id_formula = :ID_FORMULA;
	END;
  