
        CREATE TABLE t_ps_ach (
        id_payment_instrument  varchar2(40) NOT NULL,
        nm_routing_number      varchar2(20) NOT NULL,
        nm_bank_name           nvarchar2(20) NOT NULL,
        nm_bank_address        nvarchar2(255) NOT NULL,
        nm_bank_city           nvarchar2(20) NOT NULL,
        nm_bank_state          nvarchar2(20) NOT NULL,
        nm_bank_zip            nvarchar2(10) NOT NULL,
        id_country             number(10) NOT NULL,
        PRIMARY KEY (id_payment_instrument))
      