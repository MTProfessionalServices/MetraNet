
        CREATE TABLE [dbo].[t_failed_payment_details](
        [id_interval] [int] NOT NULL,
        [id_acc] [int] NOT NULL,
        [id_payment_instrument] [nvarchar](72) NOT NULL,
        [nm_invoice_num] [nvarchar](50) NOT NULL,
        [dt_invoice] [datetime] NOT NULL,
        [nm_po_number] [nvarchar](30) NULL,
		[n_amount] [decimal](22,10) NULL,
        CONSTRAINT [PK_t_failed_payment_details] PRIMARY KEY CLUSTERED
        (
        [id_interval] ASC,
        [id_acc] ASC,
        [id_payment_instrument] ASC,
		[nm_invoice_num] ASC
        )
        )
      