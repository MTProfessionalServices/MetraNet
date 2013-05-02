
        CREATE TABLE [t_foreignexchange_rates](
	          [c_src_currency] [nvarchar](3) NOT NULL,
	          [c_target_currency] [nvarchar](3) NOT NULL,
	          [dt_start] [datetime] NOT NULL,
	          [dt_end] [datetime] NOT NULL,
	          [c_conversionrate] [numeric](22,10) NOT NULL,
           CONSTRAINT [PK_t_foreignexchange_rates] PRIMARY KEY CLUSTERED 
          (
	          [c_src_currency] ASC,
	          [c_target_currency] ASC,
	          [dt_start] ASC
          )
        )
        