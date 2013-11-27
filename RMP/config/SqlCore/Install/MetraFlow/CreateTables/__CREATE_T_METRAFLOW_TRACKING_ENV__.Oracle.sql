
        create table t_mf_tracking_env
        (id_tracking nvarchar2(64) NOT NULL,
        seq_no number(10) NOT NULL,
        name nvarchar2(64) NOT NULL,
        value nvarchar2(128) NOT NULL,
        arg_type number(10) NOT NULL,
        primary key (id_tracking, seq_no, name)
        )
      