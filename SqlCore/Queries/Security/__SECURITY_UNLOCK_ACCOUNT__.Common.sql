
          update t_user_credentials 
          set num_failures_since_login = 0,
              b_enabled = 'Y', 
              dt_last_login = NULL,
              dt_expire = case when dt_expire < getdate() then NULL else dt_expire end
          where %%%UPPER%%%(nm_login) = %%%UPPER%%%(N'%%USERNAME%%') and %%%UPPER%%%(nm_space) = %%%UPPER%%%(N'%%NAME_SPACE%%')
        