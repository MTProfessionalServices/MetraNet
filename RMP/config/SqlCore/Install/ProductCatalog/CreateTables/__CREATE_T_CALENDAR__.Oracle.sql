
			CREATE TABLE t_calendar
			(
			id_calendar    number(10) NOT NULL,
			n_timezoneoffset  number(10) NOT NULL,
			b_combinedweekend char(1) NOT NULL,
			CONSTRAINT PK_t_calendar PRIMARY KEY (id_calendar)
			)
		