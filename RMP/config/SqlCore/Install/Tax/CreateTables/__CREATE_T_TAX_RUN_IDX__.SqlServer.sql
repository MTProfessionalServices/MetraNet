
        CREATE UNIQUE NONCLUSTERED INDEX idx_tax_run1 on t_tax_run
        (
          id_vendor,
          id_usage_interval,
          id_billgroup,
          dt_start,
          dt_end
        )
      