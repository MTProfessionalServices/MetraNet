
        CREATE TABLE [dbo].[t_pending_payment_trans](
				[id_pending_payment] int identity(1,1) NOT NULL,
				[id_interval] [int] NULL,
        [id_acc] [int] NOT NULL,
        [id_payment_instrument] [nvarchar](72) NOT NULL,
        [nm_description] [nvarchar](100) NULL,
        [nm_currency] [nvarchar](10) NOT NULL,
        [n_amount] [decimal](22,10) NOT NULL,
        [id_authorization] [nvarchar](72) NULL,
        [b_captured] [char](1) NOT NULL,
				[b_try_dunning] [char](1) NOT NULL,
				[b_scheduled] [char](1) NOT NULL,
				[dt_create] [datetime] NOT NULL,
				[dt_execute] [datetime] NULL,
        CONSTRAINT [PK_t_pending_payment_trans] PRIMARY KEY CLUSTERED
        (
					[id_pending_payment]
        )
        )
      