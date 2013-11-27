    
          SELECT '%%ID_PREFIX%%' + CONVERT(varchar, ID) as 'AdjustmentID',
          Type
          FROM tmp_ARReverse WHERE Namespace = '%%ACC_NAME_SPACE%%'
        