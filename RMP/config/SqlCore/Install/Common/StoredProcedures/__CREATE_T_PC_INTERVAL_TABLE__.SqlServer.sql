
      CREATE TABLE t_pc_interval
      (id_interval int NOT NULL,
      id_cycle int NOT NULL,
      dt_start datetime NOT NULL,
      dt_end datetime NOT NULL,
      CONSTRAINT PK_t_pc_interval
      PRIMARY KEY CLUSTERED (id_interval)
      )
      CREATE INDEX time_pc_interval_index  on t_pc_interval (dt_start, dt_end)
      create nonclustered index cycle_time_pc_interval_index on t_pc_interval (id_cycle, dt_start, dt_end)
    