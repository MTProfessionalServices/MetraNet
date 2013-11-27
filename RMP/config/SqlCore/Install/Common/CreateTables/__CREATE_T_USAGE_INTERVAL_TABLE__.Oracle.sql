
           CREATE TABLE t_usage_interval (id_interval number(10) NOT NULL,
         id_usage_cycle number(10) NOT NULL,
         dt_start date NOT NULL, dt_end date NOT NULL,
         tx_interval_status char(1) NOT NULL,
         CONSTRAINT PK_t_usage_interval PRIMARY KEY (id_interval),
         CONSTRAINT CK1_t_usage_interval CHECK (tx_interval_status IN ('O', 'B', 'H'))
         )
      