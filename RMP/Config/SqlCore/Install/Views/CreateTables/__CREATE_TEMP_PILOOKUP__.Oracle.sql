
  create global temporary table t_arg_pilookup
  (
    id_request number(10) not null,
    id_acc number(10) not null,
    dt_session date not null,
    id_pi_template number(10) null,
    nm_pi_name nvarchar2(256)
  )
  on commit preserve rows
