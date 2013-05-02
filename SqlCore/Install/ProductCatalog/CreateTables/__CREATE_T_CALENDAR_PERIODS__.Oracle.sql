
	CREATE TABLE t_calendar_periods
	(
	  id_period  number(10) NOT NULL,
	  id_day   number(10) NOT NULL,
	  n_begin   number(10) NOT NULL,
	  n_end    number(10) NOT NULL,
	  n_code   number(10) NOT NULL,
	  CONSTRAINT PK_t_calendar_periods PRIMARY KEY  (id_period) 
	)
