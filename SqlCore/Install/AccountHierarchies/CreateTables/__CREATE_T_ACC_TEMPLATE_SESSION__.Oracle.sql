
        create table t_acc_template_session (
        id_session number(10) not null,
        id_template_owner number(10) not null,
        nm_acc_type nvarchar2(255) not null,
        dt_submission date not null,
        id_submitter number(10) not null,
        nm_host nvarchar2(100) not null,
        n_status number(10) not null,
        n_accts number(10) not null,
        n_subs number(10) not null,
        n_retries number(4) default -1 not null,
        n_templates number(10) default 0 not null,
        n_templates_applied number(10) default 0 not null,
        constraint pk_t_acc_template_session PRIMARY KEY(id_session)
        )
      