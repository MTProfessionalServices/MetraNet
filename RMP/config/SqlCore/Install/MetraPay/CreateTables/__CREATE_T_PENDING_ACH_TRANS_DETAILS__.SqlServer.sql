
        CREATE TABLE t_pending_ACH_trans_details (
        [id_payment_transaction] [nvarchar](87) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [nm_invoice_num] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[n_amount] [decimal](22,10) NULL,
		[dt_invoice] [datetime] NULL,
		[nm_po_number] [nvarchar](30)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL
        CONSTRAINT [PK_t_pending_ach_trans_details] PRIMARY KEY CLUSTERED
        (
        [id_payment_transaction] ASC,
		[nm_invoice_num]
        ))
      