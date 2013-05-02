
				CREATE TABLE [dbo].[t_payment_instrument](
				[id_payment_instrument] [nvarchar](72) NOT NULL,
				[id_acct] [int] NULL,
				[n_payment_method_type] [int] NOT NULL,
				[nm_truncd_acct_num] [nvarchar](50) NOT NULL,
				[tx_hash] [nvarchar](255) NOT NULL,
				[id_creditcard_type] [int] NULL,
				[n_account_type] [int] NULL,
				[nm_exp_date] [nvarchar](10) NULL,
				[nm_exp_date_format] [int] NULL,
				[nm_first_name] [nvarchar](50) NOT NULL,
				[nm_middle_name] [nvarchar](50) NULL,
				[nm_last_name] [nvarchar](50) NOT NULL,
				[nm_address1] [nvarchar](255) NOT NULL,
				[nm_address2] [nvarchar](255) NULL,
				[nm_city] [nvarchar](100) NOT NULL,
				[nm_state] [nvarchar](40) NULL,
				[nm_zip] [nvarchar](10) NULL,
				[id_country] [int] NOT NULL,
				[id_priority] [int] NULL,
				[n_max_charge_per_cycle] [decimal](22,10) NULL,
				[dt_created] [datetime] NOT NULL,
				CONSTRAINT [PK_t_payment_instrument] PRIMARY KEY CLUSTERED
				(
				[id_payment_instrument] ASC
				)
				)
				Create NONCLUSTERED INDEX idx_t_payment_instrument_id_acct on t_payment_instrument(id_acct)
			