
          CREATE TABLE t_enum_capability (
          id_cap_instance number(10) NOT NULL,
          tx_param_name NVARCHAR2(2000) NULL,
          tx_op VARCHAR2(1) NOT NULL,
          param_value NUMBER(10), 
			constraint pk_t_enum_capability PRIMARY KEY(id_cap_instance)
          )
        