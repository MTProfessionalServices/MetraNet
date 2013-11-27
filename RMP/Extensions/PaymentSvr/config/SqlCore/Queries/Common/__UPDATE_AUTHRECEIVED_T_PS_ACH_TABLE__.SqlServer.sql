
        update t_ps_ach set
          nm_authreceived   = '1'
        where 
          id_acc            = %%ACCOUNT_ID%% and 
          nm_routingnumber  = N'%%ROUTINGNUMBER%%' and
	  id_accounttype    = %%ACCOUNT_TYPE%% and
          nm_lastfourdigits = N'%%LAST_FOUR_DIGITS%%'
	  