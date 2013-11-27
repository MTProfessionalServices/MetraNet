
        CREATE TABLE t_pending_ach_trans_details (
        id_payment_transaction varchar2(87) NOT NULL,
        nm_invoice_num         nvarchar2(50) NULL,
		n_amount 			   number(22,10) NULL,
		dt_invoice			   timestamp NOT NULL,
		nm_po_number		   nvarchar2(30) NULL,
        PRIMARY KEY (id_payment_transaction, nm_invoice_num))
      