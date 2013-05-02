
        update t_ps_ach set
          nm_customer       = N'%%CUSTOMER_NAME%%',
          nm_enabled        = N'%%ENABLED%%',
          nm_authreceived   = N'%%AUTHRECEIVED%%',
          nm_validated      = N'%%VALIDATED%%',
          nm_address        = N'%%ADDRESS%%',
          nm_city           = N'%%CITY%%',
          nm_state          = N'%%STATE%%',
          nm_zip            = N'%%ZIP%%',
          nm_country        = N'%%COUNTRY%%', 
          nm_bankname       = N'%%BANKNAME%%',
          nm_reserved1      = N'%%RESERVED1%%',
          nm_reserved2      = N'%%RESERVED2%%'
        WHERE 
          id_acc            = %%ACCOUNT_ID%% and 
          nm_routingnumber  = N'%%ROUTINGNUMBER%%' and
          nm_lastfourdigits = N'%%LAST_FOUR_DIGITS%%' and
          id_accounttype    = %%ACCOUNT_TYPE%%
	  