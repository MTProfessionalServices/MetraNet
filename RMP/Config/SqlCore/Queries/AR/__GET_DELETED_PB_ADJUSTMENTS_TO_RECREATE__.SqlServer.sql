    
         SELECT
          '%%ID_PREFIX%%' + CONVERT(varchar, ID) as AdjustmentID,
          RecreateType as Type,
          RecreateBatchID as BatchID,
          Description,
          AdjustmentDate,
          ExtAccountID,
          Amount,
          Currency
        FROM tmp_ARReverse
        WHERE ARDelAction = 'D' AND ExtNamespace = '%%ACC_NAME_SPACE%%'
        