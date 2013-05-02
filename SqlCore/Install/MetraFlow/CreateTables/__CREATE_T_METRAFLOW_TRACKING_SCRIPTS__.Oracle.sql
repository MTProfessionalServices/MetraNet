
        create table t_mf_tracking_scripts
        (id_tracking nvarchar2(64) PRIMARY KEY NOT NULL,
        script_name nvarchar2(128) NOT NULL,
        dt_start DATE NOT NULL,
        was_completed NUMBER(10) NOT NULL)
      