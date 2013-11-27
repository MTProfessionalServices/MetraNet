    
          SELECT '%%ID_PREFIX%%' + CONVERT(varchar, ID) as 'PaymentID'
          FROM tmp_ARReverse WHERE Namespace = '%%ACC_NAME_SPACE%%'
        