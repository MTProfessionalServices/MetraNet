
create global temporary table t_arg_intervalres
 (id_request number(10) not null,
  id_acc number(10) not null,
  dt_session date not null,
  b_override number(10) NOT NULL)
on commit preserve rows
