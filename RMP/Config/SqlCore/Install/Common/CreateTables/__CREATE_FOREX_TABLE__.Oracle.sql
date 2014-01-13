
        CREATE TABLE t_foreignexchange_rates (
	          c_src_currency nvarchar2(3) NOT NULL,
	          c_target_currency nvarchar2(3) NOT NULL,
	          dt_start date NOT NULL,
	          dt_end date NOT NULL,
	          c_conversionrate number(22,10) NOT NULL,
           CONSTRAINT PK_t_foreignexchange_rates PRIMARY KEY 
          (
	          c_src_currency,
	          c_target_currency,
	          dt_start
          )
        )
        