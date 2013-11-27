
        CREATE TABLE t_pending_ACH_trans (
        [id_payment_transaction] [nvarchar](87) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [n_days] int NOT NULL,
		[id_payment_instrument] [nvarchar](72) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[id_acc] [int] NOT NULL,
		[n_amount] [decimal](22,10) NOT NULL,
		[nm_description] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[dt_create] [datetime] NOT NULL,
		[nm_ar_request_id] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
        CONSTRAINT [PK_t_pending_ach_trans] PRIMARY KEY CLUSTERED
        (
        [id_payment_transaction] ASC
        ))
      