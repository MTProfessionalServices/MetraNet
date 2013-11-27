
			     CREATE TABLE t_usage_cycle (
					 id_usage_cycle int NOT NULL,
					 id_cycle_type int NOT NULL,
					 day_of_month int NULL,
					 tx_period_type char(1) NOT NULL,
					 day_of_week int NULL,
					 first_day_of_month int NULL,
					 second_day_of_month int NULL,
					 start_day int NULL,
					 start_month int NULL,
					 start_year int NULL,
					 CONSTRAINT PK_t_usage_cycle PRIMARY KEY CLUSTERED (id_usage_cycle))
			 