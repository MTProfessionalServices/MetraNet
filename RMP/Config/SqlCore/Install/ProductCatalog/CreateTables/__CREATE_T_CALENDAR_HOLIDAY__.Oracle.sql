
	CREATE TABLE t_calendar_holiday
	(
	  id_holiday  number(10)  NOT NULL,
	  id_day    number(10) NOT NULL,
	  nm_name    nvarchar2(255) NOT NULL,
	  n_day     number(10) NOT NULL,
	  n_weekofmonth number(10) NULL,
	  n_month    number(10) NOT NULL,
	  n_year    number(10) NOT NULL,
	  CONSTRAINT PK_t_calendar_holiday PRIMARY KEY (id_holiday) 
	)
