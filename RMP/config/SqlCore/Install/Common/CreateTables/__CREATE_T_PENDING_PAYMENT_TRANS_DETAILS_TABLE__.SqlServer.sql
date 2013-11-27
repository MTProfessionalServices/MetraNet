
              CREATE TABLE [dbo].[t_pending_payment_trans_dtl](
              [id_detail] int IDENTITY(1000,1) NOT NULL,
              [id_pending_payment] int  NOT NULL,
              [nm_invoice_num] [nvarchar](50) NULL,
              [dt_invoice] [datetime] NULL,
              [nm_po_number] [nvarchar](30) NULL,
              [n_amount] [decimal](22,10) NOT NULL,
              CONSTRAINT [PK_t_pending_payment_trans_dtl] PRIMARY KEY CLUSTERED
              (
              [id_detail]
              ),
              CONSTRAINT FK1_t_pending_payment_trans_dtl FOREIGN KEY (id_pending_payment) REFERENCES t_pending_payment_trans(id_pending_payment)
              )
            