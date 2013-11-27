
          update t_user_credentials 
          set num_failures_since_login = 0,
              b_enabled = 'Y', 
              dt_last_login = NULL
          where %%%UPPER%%%(nm_login) = %%%UPPER%%%(N'%%USERNAME%%') and %%%UPPER%%%(nm_space) = %%%UPPER%%%(N'%%NAME_SPACE%%')
        