
              CREATE TABLE t_pending_payment_trans_dtl(
              id_detail int NOT NULL,
              id_pending_payment int NOT NULL,
              nm_invoice_num nvarchar2(50) NULL,
              dt_invoice date NULL,
              nm_po_number nvarchar2(30) NULL,
              n_amount number(22,10) NOT NULL,
              CONSTRAINT PK_t_pending_payment_trans_dtl PRIMARY KEY
              (
              id_detail
              ),
              CONSTRAINT FK1_t_pend_pymt_trans_dtl FOREIGN KEY (id_pending_payment) REFERENCES t_pending_payment_trans(id_pending_payment)
              )
            