
        CREATE TABLE t_tax_run (
          id_tax_run INT NOT NULL,
          id_vendor INT NOT NULL,
          id_usage_interval INT,
          id_billgroup INT,
          dt_start DATETIME,
          dt_end DATETIME,
          CONSTRAINT PK_t_tax_run PRIMARY KEY CLUSTERED (id_tax_run)
        )
      