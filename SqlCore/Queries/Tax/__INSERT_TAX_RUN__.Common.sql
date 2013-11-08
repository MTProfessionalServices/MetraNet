
        INSERT INTO t_tax_run
        (
        id_tax_run,
        id_vendor,
        id_usage_interval,
        id_billgroup,
        dt_start,
        dt_end,
		is_audited
        ) VALUES 
        (
        %%ID_TAX_RUN%%,
        %%ID_VENDOR%%,
        %%ID_USAGE_INTERVAL%%,
        %%ID_BILLGROUP%%,
        %%DT_START%%,
        %%DT_END%%,
		'%%IS_AUDITED%%'
        )
      