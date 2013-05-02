    
        SELECT
          '%%ID_PREFIX%%' + CONVERT(varchar, ID) as AdjustmentID,
          CompensateType as Type,
          CompensateBatchID as BatchID,
          Description,
          AdjustmentDate,
          ExtAccountID,
          Amount,
          Currency
        FROM tmp_PBAdjustments
        WHERE ARDelAction = 'C'          
        