
          select top 10 
            nm_productview as 'desc'
          from
            t_pi WITH(NOLOCK)
          where 
            nm_productview like '%%%KEYWORD%%%'
    