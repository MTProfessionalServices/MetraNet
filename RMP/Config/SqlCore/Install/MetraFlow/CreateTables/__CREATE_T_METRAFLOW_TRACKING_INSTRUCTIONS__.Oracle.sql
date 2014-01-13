
        create table t_mf_tracking_instructions
          (id_tracking nvarchar2(64) NOT NULL,
          seq_no number(10) NOT NULL,
          instruction_no number(10) NOT NULL,
          dt_start DATE NOT NULL,
          dt_end DATE NULL,
          description nvarchar2(128) NOT NULL,
          primary key (id_tracking, seq_no))
      