
			  CREATE TABLE t_failed_payment_details(
			  id_interval int NOT NULL,
			  id_acc int NOT NULL,
			  id_payment_instrument nvarchar2(36) NOT NULL,
			  nm_invoice_num nvarchar2(50) NOT NULL,
			  dt_invoice date NOT NULL,
			  nm_po_number nvarchar2(30) NULL,
			  n_amount number(22,10) NULL,
			  CONSTRAINT PK_t_failed_payment_details PRIMARY KEY
			  (
			  id_interval,
			  id_acc,
			  id_payment_instrument,
			  nm_invoice_num
			  )
			  )
		  