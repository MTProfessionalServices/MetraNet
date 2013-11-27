
        SELECT id_tax_run
        FROM t_tax_run
        where id_vendor = %%ID_VENDOR%%
        and id_usage_interval = %%ID_USAGE_INTERVAL%%
        and id_billgroup = %%ID_BILLGROUP%%
        and dt_start is null
        and dt_end is null
		and is_audited = '%%IS_AUDITED%%'
      