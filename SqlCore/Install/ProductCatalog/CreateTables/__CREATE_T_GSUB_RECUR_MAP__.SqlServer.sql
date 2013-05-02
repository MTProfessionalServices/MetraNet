
  create table t_gsub_recur_map (
  id_group int not null,
  id_prop int not null,
  id_acc int not null,
  vt_start datetime not null,
  vt_end datetime not null,
  tt_start datetime not null,
  tt_end datetime not null,
  constraint t_gsub_recur_map_PK PRIMARY KEY (id_group, id_prop, vt_start, vt_end, tt_start, tt_end))
