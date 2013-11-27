
  create global temporary table tmp_closing_billgroup 
    (
      id_billgroup INT NOT NULL,
      id_interval INT NOT NULL,
      id_usage_cycle INT NOT NULL,
      id_cycle_type INT NOT NULL,
      dt_start date NOT NULL,
      dt_end date NOT NULL,
      tx_billgroup_status VARCHAR2(1) NOT NULL
    ) ON COMMIT PRESERVE ROWS
		