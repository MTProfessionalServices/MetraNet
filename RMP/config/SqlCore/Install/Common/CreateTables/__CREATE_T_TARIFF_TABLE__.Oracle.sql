
          CREATE TABLE t_tariff (id_tariff number(10) NOT NULL,
        id_enum_tariff number(10) NOT NULL, tx_currency nvarchar2(255) NOT NULL,
        CONSTRAINT PK_TARIFF PRIMARY KEY (id_enum_tariff))
       