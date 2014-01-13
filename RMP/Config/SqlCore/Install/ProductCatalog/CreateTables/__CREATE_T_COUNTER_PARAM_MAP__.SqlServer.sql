
        	CREATE TABLE t_counter_param_map
          (
             id_counter_param INT NOT NULL,
             id_counter INT NOT NULL,
             id_counter_param_meta INT NOT NULL,
             constraint t_counter_param_map_PK primary key (id_counter_param, id_counter)
           )
         