
      create table T_DISCOUNT (
        ID_PROP NUMBER(10) not null,
        n_value_type number(10) not null,
        id_usage_cycle number(10),
        id_cycle_type number(10),
        id_distribution_cpd number(10),
        constraint T_DISCOUNT_PK primary key (ID_PROP) ) 
   