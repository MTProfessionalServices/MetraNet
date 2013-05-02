
           CREATE TABLE t_usage_cycle (id_usage_cycle number(10) NOT NULL,
         id_cycle_type number(10) NOT NULL, day_of_month number(10) NULL, tx_period_type char(1) NOT NULL,
         day_of_week number(10) NULL, first_day_of_month number(10) NULL, second_day_of_month number(10) NULL,
         start_day number(10) NULL, start_month number(10) NULL, start_year number(10) NULL,
         CONSTRAINT PK_t_usage_cycle PRIMARY KEY
         (id_usage_cycle))
       