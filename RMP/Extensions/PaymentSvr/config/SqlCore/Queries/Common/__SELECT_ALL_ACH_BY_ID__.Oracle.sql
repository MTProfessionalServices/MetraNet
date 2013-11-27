
        SELECT
          tpach.nm_routingnumber,
          tpach.nm_lastfourdigits,
          tpach.id_accounttype,
          tpach.nm_bankname
        from
          t_ps_ach tpach
        WHERE 
          tpach.id_acc = %%ACCOUNT_ID%%
	  