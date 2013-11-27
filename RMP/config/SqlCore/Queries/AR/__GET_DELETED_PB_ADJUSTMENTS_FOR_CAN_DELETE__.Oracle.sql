    
    SELECT '%%ID_PREFIX%%' || to_char(ID) as "AdjustmentID",
      DelType as Type
    FROM tmp_PBAdjustments
      