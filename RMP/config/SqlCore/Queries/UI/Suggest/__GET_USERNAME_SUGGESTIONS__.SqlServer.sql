
          select top 10
            displayname as 'desc'
          from
            vw_mps_acc_mapper WITH(NOLOCK)
          where
            displayname like '%%%KEYWORD%%%'
    