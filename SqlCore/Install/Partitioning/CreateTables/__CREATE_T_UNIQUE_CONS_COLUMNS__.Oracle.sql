
      create table t_unique_cons_columns (
        id_unique_cons number(10) not null ,
        id_prod_view_prop number(10) not null ,
        position number(10) not null ,
        constraint pk_t_unique_cons_col primary key 
        (
          id_unique_cons,
          id_prod_view_prop
        )  ,
        constraint uk1_t_unique_cons_col unique 
        (
          id_unique_cons,
          position
        )  
      )
      