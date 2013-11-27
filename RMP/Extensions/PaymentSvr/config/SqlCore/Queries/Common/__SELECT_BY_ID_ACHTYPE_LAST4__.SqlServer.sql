
        SELECT
          tpach.id_acc,
          tpach.nm_customer,
          tpach.nm_routingnumber,
          tpach.nm_accountnumber,
          tpach.id_accounttype,
          tpach.id_acc,
          tpach.nm_primary,
          tpach.nm_enabled,
          tpach.nm_authreceived,
          tpach.nm_validated,
          tpach.nm_address,
          tpach.nm_city,
          tpach.nm_state,
          tpach.nm_zip, 
          tpach.nm_country, 
          tpach.nm_bankname,
          tpach.nm_lastfourdigits,
          tpach.nm_reserved1,
          tpach.nm_reserved2
        FROM 
          t_ps_ach     tpach
        WHERE 
          tpach.id_acc            = %%ACCOUNT_ID%% and 
          tpach.nm_routingnumber  = N'%%ROUTINGNUMBER%%' and
          tpach.nm_lastfourdigits = N'%%LAST_FOUR_DIGITS%%' and
          tpach.id_accounttype    = %%ACCOUNT_TYPE%%
	  