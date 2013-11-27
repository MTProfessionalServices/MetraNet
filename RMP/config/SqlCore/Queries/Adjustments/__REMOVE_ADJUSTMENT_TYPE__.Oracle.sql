
    BEGIN
    DELETE FROM T_CALC_FORMULA WHERE id_formula = 
        (SELECT id_formula from t_adjustment_type WHERE id_prop = %%ID_PROP%%);
    DELETE FROM T_AJ_TEMPLATE_REASON_CODE_MAP WHERE id_adjustment IN
    (SELECT id_adjustment from  T_ADJUSTMENT where id_adjustment_type = %%ID_PROP%%);
    DELETE FROM T_ADJUSTMENT WHERE id_adjustment_type = %%ID_PROP%%;
    RemoveAdjustmentTypeProps(%%ID_PROP%%);
    DELETE FROM T_ADJUSTMENT_TYPE WHERE id_prop = %%ID_PROP%%;
    END;
  