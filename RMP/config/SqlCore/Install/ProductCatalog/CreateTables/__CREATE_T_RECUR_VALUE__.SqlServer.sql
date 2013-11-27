
  create table t_recur_value (
  id_prop int not null,
  id_sub int not null,
  n_value numeric(22,10) not null,
  vt_start datetime not null,
  vt_end datetime not null,
  tt_start datetime not null,
  tt_end datetime not null,
  constraint t_recur_value_PK primary key (id_prop, id_sub, vt_start, vt_end, tt_start, tt_end))
