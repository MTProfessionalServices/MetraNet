    
          SELECT '%%ID_PREFIX%%' || ID as AdjustmentID,
          Type
          FROM tmp_ARReverse WHERE Namespace = '%%ACC_NAME_SPACE%%'
        