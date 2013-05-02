
        CREATE TABLE t_ps_audit_details (
		id_audit_detail NUMBER(10) NOT NULL,
        id_audit VARCHAR2(40) NOT NULL,
        nm_invoice_num nvarchar2(50) NULL,
        dt_invoice_date timestamp NULL,
        nm_po_number nvarchar2(30) NULL,
		n_amount numeric(22,10) NULL,
        PRIMARY KEY (id_audit_detail, id_audit))
      