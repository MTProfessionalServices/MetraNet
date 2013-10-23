
        SELECT id_tax_run
        FROM t_tax_run
        where id_vendor = %%ID_VENDOR%%
        and id_usage_interval is null
        and id_billgroup is null
        and dt_start = %%DT_START%%
        and dt_end = %%DT_END%%
		and is_audited = '%%IS_AUDITED%%'
      