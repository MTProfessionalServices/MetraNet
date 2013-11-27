
          CREATE TABLE t_spec_val_map
          (
             id_spec	int not null,
             id_scv int not null,
             constraint t_spec_val_map_PK primary key (id_spec,id_scv),
             constraint fk1_t_spec_val_map foreign key (id_spec) references t_spec_characteristics(id_spec),
             constraint fk2_t_spec_val_map foreign key (id_scv) references t_spec_char_values(id_scv)
           )
         