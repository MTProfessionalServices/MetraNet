
       create table t_pc_interval (id_interval number(10) NOT NULL,
       id_cycle number(10) NOT NULL,
       dt_start date NOT NULL,
       dt_end date NOT NULL,
       CONSTRAINT PK_t_pc_interval
       PRIMARY KEY (id_interval)
       )
        