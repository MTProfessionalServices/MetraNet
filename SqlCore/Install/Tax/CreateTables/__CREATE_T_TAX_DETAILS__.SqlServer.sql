  create table t_tax_details (
        id_tax_detail int not null,
        id_tax_charge bigint not null,
        id_acc int not null,
        id_usage_interval int not null,
        id_tax_run int not null,
        dt_calc datetime not null,
        tax_amount decimal(22, 10) not null,
        rate decimal(22, 10) not null,
        tax_jur_level int not null,
        tax_jur_name nvarchar(255) not null,
        tax_type int not null,
        tax_type_name nvarchar(255) not null,
        is_implied nvarchar(10) null,
        notes nvarchar(255) null, 
        constraint pk_t_tax_details primary key(id_tax_run, id_tax_detail, id_tax_charge, id_usage_interval)
        )