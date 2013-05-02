
           CREATE TABLE t_account_mapper (nm_login nvarchar2(255) NOT NULL,
         nm_space nvarchar2(40) NOT NULL, id_acc number(10) NOT
         NULL, CONSTRAINT PK_t_account_mapper PRIMARY KEY
         (nm_login, nm_space))
       