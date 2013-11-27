
		CREATE TABLE t_calendar
		(
			id_calendar 			int NOT NULL,
			n_timezoneoffset 	int NOT NULL,
			b_combinedweekend char(1) NOT NULL,
			CONSTRAINT PK_t_calendar PRIMARY KEY CLUSTERED (id_calendar)
		)
		