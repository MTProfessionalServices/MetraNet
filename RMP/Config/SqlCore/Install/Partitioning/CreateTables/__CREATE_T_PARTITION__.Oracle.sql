       
      CREATE TABLE t_partition (
        id_partition number(10) NOT NULL ,
        partition_name nvarchar2 (30) NOT NULL ,
        dt_start date NOT NULL ,
        dt_end date NOT NULL ,
        id_interval_start number(10) NOT NULL ,
        id_interval_end number(10) NOT NULL ,
        b_default char (1) NOT NULL ,
        b_active char (1) NOT NULL ,
        CONSTRAINT pk_t_partition PRIMARY KEY 
        (
          id_partition
        )  ,
        CONSTRAINT uk1_t_partition UNIQUE
        (
          partition_name
        )  
      ) 
      