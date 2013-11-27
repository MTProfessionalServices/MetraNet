
        CREATE TABLE t_ps_preauth (
        id_preauth_tx_id VARCHAR2(40) NOT NULL,
        id_pymt_instrument VARCHAR2(40) NOT NULL,
        dt_transaction timestamp NOT NULL,
        nm_description nvarchar2(10) NULL,
        n_currency nvarchar2(10) NOT NULL,
        n_amount decimal NOT NULL,
        n_request_params nvarchar2(256) NOT NULL,
		nm_ar_request_id nvarchar2(256) NULL,
        PRIMARY KEY (id_preauth_tx_id))
      