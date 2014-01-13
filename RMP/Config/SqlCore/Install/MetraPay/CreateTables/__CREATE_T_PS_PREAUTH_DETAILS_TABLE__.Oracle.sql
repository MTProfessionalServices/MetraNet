
        CREATE TABLE t_ps_preauth_details (
		id_preauth_tx_id_detail NUMBER(10) NOT NULL,
        id_preauth_tx_id VARCHAR2(40) NOT NULL,
        nm_invoice_num nvarchar2(255) NULL,
        dt_invoice_date timestamp NULL,
        nm_po_number nvarchar2(20) NULL,
		n_amount decimal NULL,
        PRIMARY KEY (id_preauth_tx_id_detail, id_preauth_tx_id))
      