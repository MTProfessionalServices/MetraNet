
         update t_user_credentials 
            set dt_auto_reset_failures =  %%AUTO_RESET_FAILURE_DATE%%,
                num_failures_since_login = (case when num_failures_since_login is null then 1 
                                            else num_failures_since_login + 1 end)
         where %%%UPPER%%%(nm_login) = %%%UPPER%%%(N'%%USERNAME%%') and %%%UPPER%%%(nm_space) = %%%UPPER%%%(N'%%NAME_SPACE%%')
        