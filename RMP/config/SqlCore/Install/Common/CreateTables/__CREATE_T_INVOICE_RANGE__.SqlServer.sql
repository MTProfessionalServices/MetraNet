
			    CREATE TABLE t_invoice_range
			    (
					id_interval int NOT NULL,
					id_billgroup int NOT NULL,
					namespace nvarchar(40) NOT NULL,
					id_invoice_num_first int NOT NULL,
					id_invoice_num_last int NOT NULL,
					id_run int NULL
				)
			