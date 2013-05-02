
			     CREATE TABLE t_nonrecurring_event_run (id_run number(10) NOT NULL, 
           id_interval number(10) NOT NULL, dt_start date NOT NULL, 
           dt_end date NULL, tx_adapter_name varchar(80) NOT NULL, 
           tx_adapter_method varchar(255) NOT NULL, tx_config_file varchar(255) NOT NULL,
           CONSTRAINT PK_t_nonrecurring_event_run PRIMARY KEY (id_run))
			 