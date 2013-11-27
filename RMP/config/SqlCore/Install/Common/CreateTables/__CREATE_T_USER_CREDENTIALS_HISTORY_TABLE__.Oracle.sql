
        CREATE TABLE t_user_credentials_history (
        nm_login nvarchar2(255) NOT NULL,
        nm_space nvarchar2(40) NOT NULL,
        tx_password nvarchar2(1024) NOT NULL,
        tt_end date NULL,
        CONSTRAINT PK_t_user_credentials_history PRIMARY KEY
        (nm_login, nm_space, tt_end))
      