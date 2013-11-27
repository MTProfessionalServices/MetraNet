    
          SELECT '%%ID_PREFIX%%' + CONVERT(varchar, ID) as AdjustmentID,
            DelType as Type
          FROM tmp_PBAdjustments
          WHERE ARDelAction = 'D'
        