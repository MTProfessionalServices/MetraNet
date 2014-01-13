
			     CREATE TABLE t_nonrecurring_event_run 
			     (id_run int identity(1,1) NOT NULL, 
				 id_interval int NOT NULL, 
				 dt_start datetime NOT NULL, 
				 dt_end datetime NULL, 
				 tx_adapter_name varchar(80) NOT NULL, 
				 tx_adapter_method varchar(255) NOT NULL, 
				 tx_config_file varchar(255) NOT NULL,
				 CONSTRAINT PK_t_nonrecurring_event_run PRIMARY KEY CLUSTERED (id_run))
			 