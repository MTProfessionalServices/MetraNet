
        	CREATE TABLE t_char_values
          (
             id_scv	int not null,
             id_entity int not null,
             nm_value	nvarchar(255),
             c_start_date datetime not null,
             c_end_date datetime,
             c_spec_name nvarchar(20) not null,
             c_spec_type int not null,
             constraint t_char_values_PK primary key (id_scv, id_entity),
             constraint fk1_t_char_values foreign key (id_scv) references t_spec_char_values(id_scv)
           )
         