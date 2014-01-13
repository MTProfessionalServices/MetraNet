
        CREATE TABLE [dbo].[t_failed_payment](
        [id_interval] [int] NOT NULL,
        [id_acc] [int] NOT NULL,
        [id_payment_instrument] [nvarchar](72) NOT NULL,
        [dt_original_trans] [datetime] NOT NULL,
        [nm_description] [nvarchar](100) NULL,
        [nm_currency] [nvarchar](10) NOT NULL,
        [n_amount] [decimal](22,10) NOT NULL,
		[n_retrycount] [int] NULL,
		[dt_lastretry] [datetime] NULL,
        CONSTRAINT [PK_t_failed_payment] PRIMARY KEY CLUSTERED
        (
        [id_interval] ASC,
        [id_acc] ASC,
        [id_payment_instrument] ASC
        )
        )
      