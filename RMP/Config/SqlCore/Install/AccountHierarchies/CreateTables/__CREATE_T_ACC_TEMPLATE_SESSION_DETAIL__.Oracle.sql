
        create table t_acc_template_session_detail (
        id_detail number(10),
        id_session number(10) not null,
        n_detail_type number(10) not null,
        n_result number(10) not null,
        dt_detail date not null,
        nm_text nvarchar2(2000) not null,
        n_retry_count number(4),
        constraint pk_template_session_detail PRIMARY KEY(id_detail)
        )
      