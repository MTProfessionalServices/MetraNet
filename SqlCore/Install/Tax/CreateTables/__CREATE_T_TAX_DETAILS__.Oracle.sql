
        create table t_tax_details (
        id_tax_detail number(10) not null,
        id_tax_charge number(20) not null,
        id_acc number(10) not null,
        id_usage_interval number(10) not null,
        id_tax_run number(10) not null,
        dt_calc TIMESTAMP not null,
        tax_amount decimal(22, 10) not null,
        rate decimal(22, 10) not null,
        tax_jur_level number(10) not null,
        tax_jur_name nvarchar2(255) not null,
        tax_type number(10) not null,
        tax_type_name nvarchar2(255) not null,
        is_implied nvarchar2(10) DEFAULT 'N',
        notes nvarchar2(255) null,
        constraint PK_T_TAX_DETAILS primary key (id_usage_interval, id_tax_charge, id_tax_detail, id_tax_run))
      