
      create table t_partition_storage (
        id_path number(10) not null ,
        b_next char (1) ,
        path varchar2 (500), 
        constraint pk_t_partition_storage primary key 
        (
          id_path
        ) 
      ) 
   