
    /* __UPDATE_CALC_FORMULA_BY_ADJUSMENT_TYPE_ID__ */
      DECLARE
    v_long_text CLOB;
	BEGIN
		v_long_text:=:TX_TEXT;
		
      UPDATE t_calc_formula SET
      tx_formula = v_long_text,
      id_engine = :ID_ENGINE
      WHERE id_formula = 
      (SELECT id_formula FROM t_adjustment_type WHERE
      id_prop = :ID_AJ_TYPE);
	END;

