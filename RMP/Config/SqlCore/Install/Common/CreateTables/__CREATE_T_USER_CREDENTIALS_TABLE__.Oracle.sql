
         CREATE TABLE t_user_credentials (
         nm_login nvarchar2(255) NOT NULL,
         nm_space nvarchar2(40) NOT NULL,
         tx_password nvarchar2(1024) NOT NULL,
         dt_expire date NULL,
         dt_last_login date NULL,
         dt_last_logout date NULL,
         num_failures_since_login number(10) NULL,
         dt_auto_reset_failures date NULL,
         b_enabled nvarchar2(1) NULL,
         CONSTRAINT PK_t_user_credentials PRIMARY KEY
         (nm_login, nm_space))
       