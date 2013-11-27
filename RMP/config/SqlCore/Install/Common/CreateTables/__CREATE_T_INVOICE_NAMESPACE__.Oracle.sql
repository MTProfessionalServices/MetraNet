
			    CREATE TABLE t_invoice_namespace
			    (
					namespace nvarchar2(40) NOT NULL,
					invoice_prefix nvarchar2(40) NULL,
					invoice_suffix nvarchar2(40) NULL,
					invoice_num_digits number(10) NOT NULL,
					invoice_due_date_offset number(10) NOT NULL,
					id_invoice_num_last number(10) NOT NULL,
					CONSTRAINT PK_t_invoice_namespace PRIMARY KEY (namespace)
				)
			