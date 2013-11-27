
        CREATE TABLE t_ps_credit_card (
        id_payment_instrument VARCHAR2(40) NOT NULL,
        n_credit_card_type number(10) NOT NULL,
        nm_expirationdt varchar2(20) NOT NULL,
        nm_expirationdt_format number(10) NOT NULL,
        nm_startdate varchar2(20) NULL,
        nm_issuernumber varchar2(20) NULL,
        PRIMARY KEY (id_payment_instrument))
      