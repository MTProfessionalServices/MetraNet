
          update t_user_credentials 
          set tx_password = N'%%HASHED_PASSWORD%%'
          where %%%UPPER%%%(nm_login) = %%%UPPER%%%(N'%%USERNAME%%') and %%%UPPER%%%(nm_space) = %%%UPPER%%%(N'%%NAME_SPACE%%')
        