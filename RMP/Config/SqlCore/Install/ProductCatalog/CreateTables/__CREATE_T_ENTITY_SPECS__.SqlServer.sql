
          CREATE TABLE t_entity_specs
          (
             id_entity	int not null,
             id_spec	int not null,
             c_display_order int,
             entity_type int
             constraint fk1_t_entity_specs foreign key (id_spec) references t_spec_characteristics(id_spec)
           )
         