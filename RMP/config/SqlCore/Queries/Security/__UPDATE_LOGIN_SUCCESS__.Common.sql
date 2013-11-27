
         update t_user_credentials 
            set dt_auto_reset_failures = null,
                num_failures_since_login = 0,
                dt_last_login = %%%SYSTEMDATE%%%
         where %%%UPPER%%%(nm_login) = %%%UPPER%%%(N'%%USERNAME%%') and %%%UPPER%%%(nm_space) = %%%UPPER%%%(N'%%NAME_SPACE%%')
        