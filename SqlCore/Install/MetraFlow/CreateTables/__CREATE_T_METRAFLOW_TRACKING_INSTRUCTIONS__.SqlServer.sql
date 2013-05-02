
        create table t_mf_tracking_instructions (
        id_tracking nvarchar(64) NOT NULL,
        seq_no int NOT NULL,
        instruction_no int NOT NULL,
        dt_start datetime NOT NULL,
        dt_end datetime NULL,
        description nvarchar(128) NOT NULL,
        primary key (id_tracking, seq_no))
      