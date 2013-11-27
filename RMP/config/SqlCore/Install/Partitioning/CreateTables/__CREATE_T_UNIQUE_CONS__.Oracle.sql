
        create table t_unique_cons (
          id_unique_cons number(10) not null ,
          id_prod_view number(10) not null ,
          constraint_name nvarchar2 (400) not null ,
          nm_table_name nvarchar2 (400) not null ,
          constraint pk_t_unique_cons primary key 
          (
            id_unique_cons
          ) ,
          constraint uk1_t_unique_cons unique
          (
            constraint_name
          )
        )
      