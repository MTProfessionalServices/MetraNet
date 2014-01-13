
        select c_conversionrate from
		      t_foreignexchange_rates
	      where
		      c_src_currency = @srcCurrency
		      and
		      c_target_currency = @tgtCurrency
		      and
		      @conversionDate between dt_start and dt_end
        