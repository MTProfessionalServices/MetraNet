
		CREATE TABLE t_calendar_holiday
		(
			id_holiday		int IDENTITY (1, 1) NOT NULL,
			id_day				int NOT NULL,
			nm_name				nvarchar(255) NOT NULL,
			n_day					int NOT NULL,
			n_weekofmonth	int NULL,
			n_month				int NOT NULL,
			n_year				int NOT NULL,
			CONSTRAINT PK_t_calendar_holiday PRIMARY KEY CLUSTERED (id_holiday)
		)
		