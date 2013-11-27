
          create table t_adjustment (
          id_prop NUMBER(10) primary key not null,
          tx_guid RAW(16) null,
          id_pi_template NUMBER(10) null,
          id_pi_instance NUMBER(10) null,
          id_adjustment_type NUMBER(10) not null,
          CONSTRAINT aj_template_instance1 CHECK 	((id_pi_template IS NOT NULL AND id_pi_instance IS NULL) OR
          (id_pi_template IS NULL AND id_pi_instance IS NOT NULL))
          )
        