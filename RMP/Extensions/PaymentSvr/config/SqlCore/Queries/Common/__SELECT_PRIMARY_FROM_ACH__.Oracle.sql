
        SELECT
          nm_routingnumber,
          nm_lastfourdigits,
          id_accounttype
        FROM 
          t_ps_ach
        WHERE 
          id_acc            =  %%ACCOUNT_ID%% and 
          nm_routingnumber  =  N'%%ROUTINGNUMBER%%' and
          nm_lastfourdigits =  N'%%LAST_FOUR_DIGITS%%' and
          id_accounttype    =  %%ACCOUNT_TYPE%% and 
          nm_primary        =  '%%PRIMARY%%'
	  