
        begin
             if table_exists('%%TMP_TABLE_NAME%%') then
                execute immediate 'DROP TABLE %%TMP_TABLE_NAME%%';
             end if;
             execute immediate 'CREATE TABLE %%TMP_TABLE_NAME%%
                (
                id_request              number(10)          NOT NULL,
                id_acc_ext              raw(16)             NULL,
                acc_state               varchar2(2)         NOT NULL,
                acc_status_ext          number(10)          NULL,   
                acc_vtstart             date                NULL,
                acc_vtend               date                NULL,
                nm_login                nvarchar2(255)      NOT NULL,
                nm_space                nvarchar2(40)       NOT NULL,
                tx_password             nvarchar2(1024)       NOT NULL,
                langcode                varchar2(10)        NOT NULL,
                profile_timezone        number(10)          NOT NULL,
                id_cycle_type           number(10)          NULL,
                day_of_month            number(10)          NULL,
                day_of_week             number(10)          NULL,
                first_day_of_month      number(10)          NULL,
                second_day_of_month     number(10)          NULL,
                start_day               number(10)          NULL,
                start_month             number(10)          NULL,
                start_year              number(10)          NULL,
                billable                varchar2(1)         NOT NULL,
                id_payer                number(10)          NULL,
                payer_startdate         date                NULL,
                payer_enddate           date                NULL,
                payer_login             nvarchar2(255)      NULL,
                payer_namespace         nvarchar2(40)       NULL,
                id_ancestor             number(10)          NULL,
                hierarchy_start         date                NULL,
                hierarchy_end           date                NULL,
                ancestor_name           nvarchar2(255)      NULL,
                ancestor_namespace      nvarchar2(40)       NULL,
                acc_type                varchar2(40)        NOT NULL,
                apply_default_policy    varchar2(1)         NOT NULL,
                account_currency        nvarchar2(5)        NULL,
                id_profile              number(10)          NOT NULL,
                login_app               varchar2(10)        NULL,
                id_site                 number(10)          NULL,
                id_usage_cycle          number(10)          NULL,
                folder                  varchar2(1)         NULL,
                account_id_as_string    nvarchar2(50)       NULL,
                auth_ancestor           number(10)          NULL,
                billable_payer          varchar2(1)         NULL,
                same_corporation        varchar2(1)         NULL,
                parent_login            nvarchar2(255)      NULL,
                parent_policy           number(10)          NULL,
                child_policy            number(10)          NULL,
                id_account              number(10)          NULL,
                status                  number(10)          NULL,
                hierarchy_path          varchar2(4000)      NULL,
                id_ancestor_out         number(10)          NULL,
                id_corporation          number(10)          NULL,
                ancestor_type           varchar2(40)        NULL
                )';
		          execute immediate 'CREATE INDEX %%TMP_TABLE_IDX_NAME%% ON %%TMP_TABLE_NAME%% (id_account)';
       end;
      