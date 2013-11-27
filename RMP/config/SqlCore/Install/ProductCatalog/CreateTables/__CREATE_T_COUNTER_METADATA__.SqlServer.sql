
          create table t_counter_metadata ( id_prop int not null,
                                          FormulaTemplate nvarchar(256) not null,
                                          b_valid_for_dist char(1),
                                          constraint t_counter_metadata_PK primary key (id_prop))   
       