
		CREATE TABLE t_calendar_day
		(
			id_day 			int IDENTITY (1, 1) NOT NULL,
			id_calendar int NOT NULL,
			n_weekday		int	NULL,
			n_code			int NOT NULL, /* Default calendar code for this day - peak, off-peak, weekend, and holiday */
			CONSTRAINT PK_t_calendar_day PRIMARY KEY CLUSTERED (id_day)
		)
		