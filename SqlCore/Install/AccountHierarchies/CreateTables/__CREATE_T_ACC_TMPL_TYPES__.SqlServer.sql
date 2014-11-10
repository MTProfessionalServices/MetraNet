
create table t_acc_tmpl_types
(
  id int NOT NULL,
  all_types INT NOT NULL,
  CONSTRAINT pk_t_acc_tmpl_types PRIMARY KEY CLUSTERED (id),
  CONSTRAINT ck_t_acc_tmpl_types CHECK  ((id=(1)))
)
