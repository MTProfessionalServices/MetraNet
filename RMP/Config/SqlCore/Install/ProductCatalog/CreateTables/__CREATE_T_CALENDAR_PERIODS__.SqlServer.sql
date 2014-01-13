
		CREATE TABLE t_calendar_periods
		(
			id_period		int IDENTITY (1, 1) NOT NULL,
			id_day			int NOT NULL,
			n_begin			int NOT NULL,
			n_end				int NOT NULL,
			n_code			int NOT NULL,
			CONSTRAINT PK_t_calendar_periods PRIMARY KEY CLUSTERED (id_period)
		)
		