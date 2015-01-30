
        create table t_acc_template_session (
          id_session int not null,
          id_template_owner int not null,
          nm_acc_type nvarchar(255) not null,
          dt_submission datetime not null,
          id_submitter int not null,
          nm_host nvarchar(100) not null,
          n_status int not null,
          n_accts int not null,
          n_subs int not null,
          n_retries int not null default(-1),
          n_templates int not null default(0),
          n_templates_applied int not null default(0),
          constraint pk_t_acc_template_session PRIMARY KEY(id_session)
        )
      