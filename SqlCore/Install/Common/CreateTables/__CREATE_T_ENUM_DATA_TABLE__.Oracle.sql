
           CREATE TABLE t_enum_data (
              nm_enum_data nvarchar2(255) NOT NULL,
              id_enum_data number(10) NOT NULL,
              CONSTRAINT PK_t_enum_data PRIMARY KEY (id_enum_data)
           );

           create unique index funiq_t_enum_data on t_enum_data(upper(nm_enum_data));

           CREATE UNIQUE INDEX IDX_ENUM_ID_DATA ON T_ENUM_DATA (ID_ENUM_DATA, UPPER(NM_ENUM_DATA));