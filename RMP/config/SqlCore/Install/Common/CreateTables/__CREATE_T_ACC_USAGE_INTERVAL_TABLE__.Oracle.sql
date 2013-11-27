
           CREATE TABLE t_acc_usage_interval (id_acc number(10) NOT NULL,
         id_usage_interval number(10) NOT NULL, tx_status char(1) NOT NULL,
         dt_effective date NULL,
         CONSTRAINT PK_t_acc_usage_interval PRIMARY KEY
         (id_acc, id_usage_interval))
       