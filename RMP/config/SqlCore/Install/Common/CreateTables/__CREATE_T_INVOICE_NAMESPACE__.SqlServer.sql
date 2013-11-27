
			    CREATE TABLE t_invoice_namespace
			    (
					namespace nvarchar(40) NOT NULL,
					invoice_prefix nvarchar(40) NULL,
					invoice_suffix nvarchar(40) NULL,
					invoice_num_digits int NOT NULL,
					invoice_due_date_offset int NOT NULL,
					id_invoice_num_last int NOT NULL,
					CONSTRAINT PK_t_invoice_namespace PRIMARY KEY CLUSTERED (namespace)
				)
			