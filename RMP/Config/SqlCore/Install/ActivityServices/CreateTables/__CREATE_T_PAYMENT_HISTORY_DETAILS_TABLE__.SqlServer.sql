	
				CREATE TABLE t_payment_history_details (

				id_payment_transaction nvarchar(72)NOT NULL,
				id_payment_history_details int NOT NULL,
				nm_invoice_num nvarchar(50) NULL,
				dt_invoice_date datetime NULL,
				nm_po_number nvarchar(30) NULL,
				n_amount decimal(16,2) NULL,
				nm_provider_info nvarchar(50) NULL

				CONSTRAINT PK_t_pending_history_details PRIMARY KEY CLUSTERED

				(
					id_payment_transaction,
					id_payment_history_details
				))


				