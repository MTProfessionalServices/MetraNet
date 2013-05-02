
          CREATE TABLE t_spec_char_values
          (
             id_scv int not null,
             c_is_default	char(1) not null,
             n_value int not null,
             nm_value	nvarchar2(20) not null,
             constraint t_spec_char_values_PK primary key (id_scv)
           )
         