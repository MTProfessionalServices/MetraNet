
          select
            displayname as 'desc'
          from
            vw_mps_acc_mapper
          where
            displayname like '%%%KEYWORD%%%'
            and rownum <= 10
    