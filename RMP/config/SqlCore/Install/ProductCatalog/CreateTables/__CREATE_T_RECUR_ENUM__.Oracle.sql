    create table t_recur_enum (id_prop number(10) not null, enum_value decimal(22,10) not null, constraint pk_t_recur_enum primary key (id_prop, enum_value), constraint fk1_t_recur_enum foreign key (id_prop) references t_recur(id_prop));

