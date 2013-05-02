
    create table t_mf_tracking_env (
     id_tracking nvarchar(64) NOT NULL,
     seq_no int NOT NULL,
     name nvarchar(64) NOT NULL,
     value nvarchar(128) NOT NULL,
     arg_type int NOT NULL,
     primary key (id_tracking, seq_no, name)
    )
		