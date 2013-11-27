    
          SELECT '%%ID_PREFIX%%' || ID as AdjustmentID,
            DelType as Type
          FROM tmp_PBAdjustments
          WHERE ARDelAction = 'D'
        