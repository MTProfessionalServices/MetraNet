
			     CREATE TABLE t_acc_usage_interval
			     (
			     id_acc int NOT NULL,
				 id_usage_interval int NOT NULL,
				 tx_status char(1) NOT NULL,
				 dt_effective datetime NULL,
				 CONSTRAINT PK_t_acc_usage_interval PRIMARY KEY CLUSTERED (id_acc, id_usage_interval))
			 