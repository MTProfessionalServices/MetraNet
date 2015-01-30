
        create table t_acc_template_session_detail (
        id_detail int identity(1,1),
        id_session int not null,
        n_detail_type int not null,
        n_result int not null,
        dt_detail datetime not null,
        nm_text nvarchar(4000) not null,
        n_retry_count int,
        constraint pk_t_acc_template_session_detail PRIMARY KEY(id_detail)
        )
      