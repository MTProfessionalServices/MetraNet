
				  CREATE TABLE t_payment_history_details (
	              id_payment_transaction VARCHAR2(40) NOT NULL,
                  id_payment_history_details integer NOT NULL,
	              nm_invoice_num nvarchar2(50) NULL,
	              dt_invoice_date timestamp NULL,
	              nm_po_number nvarchar2(30) NULL,
                  n_amount NUMERIC(16,2) NULL,
				  nm_provider_info VARCHAR2(50) NULL,
	              PRIMARY KEY (id_payment_transaction, id_payment_history_details))	 
				