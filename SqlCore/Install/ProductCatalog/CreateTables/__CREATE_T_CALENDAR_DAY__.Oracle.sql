 
	CREATE TABLE t_calendar_day
	(
	  id_day    number(10) NOT NULL,
	  id_calendar number(10) NOT NULL,
	  n_weekday  number(10) NULL,
	  n_code   number(10) NOT NULL, /* Default calendar code for this day - peak, off-peak, weekend, and holiday */
	  CONSTRAINT PK_t_calendar_day PRIMARY KEY (id_day) 
	)
