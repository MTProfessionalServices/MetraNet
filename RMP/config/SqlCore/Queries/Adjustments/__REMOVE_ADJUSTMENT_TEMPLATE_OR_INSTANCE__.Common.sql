
    BEGIN
          DELETE FROM T_AJ_TEMPLATE_REASON_CODE_MAP WHERE id_adjustment = %%ID_PROP%%;
          DELETE FROM T_ADJUSTMENT WHERE id_prop = %%ID_PROP%%;
    END;
  