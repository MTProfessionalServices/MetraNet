
          select 
            nm_productview as 'desc'
          from
            t_pi 
          where 
            nm_productview like '%%%KEYWORD%%%'
            and rownum <= 10
    