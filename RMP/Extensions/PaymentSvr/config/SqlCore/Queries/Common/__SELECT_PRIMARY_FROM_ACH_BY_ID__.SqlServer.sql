
        SELECT
          nm_routingnumber,
          nm_lastfourdigits,
          id_accounttype
        FROM 
          t_ps_ach
        WHERE 
          id_acc            =  %%ACCOUNT_ID%% and 
          nm_primary        =  N'%%PRIMARY%%'
	  