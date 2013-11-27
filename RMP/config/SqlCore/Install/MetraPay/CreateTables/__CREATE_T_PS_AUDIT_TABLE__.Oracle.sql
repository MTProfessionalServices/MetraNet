
        CREATE TABLE t_ps_audit (
        id_audit VARCHAR2(40) NOT NULL,
        id_request_type number(10) NOT NULL,
        id_transaction nvarchar2(50) NOT NULL,
        dt_transaction timestamp NOT NULL,
        n_payment_method_type number(10) NOT NULL,
        nm_truncd_acct_num nvarchar2(20) NOT NULL,
        n_creditcard_type number(10) NULL,
        n_account_type number(10) NULL,
        nm_description nvarchar2(100) NOT NULL,
        n_currency nvarchar2(10) NOT NULL,
        n_amount numeric(22,10) NOT NULL,
        id_transaction_session_id varchar2(40) NOT NULL,
        n_state nvarchar2(30) NOT NULL,
        n_gateway_response nvarchar2(400) NULL,
        dt_last_update timestamp NOT NULL,
        PRIMARY KEY (id_audit))
      