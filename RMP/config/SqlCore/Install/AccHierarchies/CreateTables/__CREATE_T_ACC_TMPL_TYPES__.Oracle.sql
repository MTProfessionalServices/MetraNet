
create table t_acc_tmpl_types
(
  id number(10) NOT NULL,
  all_types number(1) NOT NULL,
  CONSTRAINT pk_t_acc_tmpl_types PRIMARY KEY (id),
  CONSTRAINT ck_t_acc_tmpl_types CHECK ((id=(1)))
)
