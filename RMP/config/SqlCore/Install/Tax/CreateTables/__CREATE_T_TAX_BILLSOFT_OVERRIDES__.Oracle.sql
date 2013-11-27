
        create table t_tax_billsoft_override (
        id_tax_override	int not null,
        id_ancestor	int not null,
        id_acc int not null,
        pcode	int not null,
        scope	int not null,
        tax_type	int not null,
        jur_level	int not null,
        effectiveDate	timestamp not null,
        levelExempt	nvarchar2(10) DEFAULT 'FALSE',
        tax_rate decimal(22, 10) not null,
        maximum decimal(22, 10) not null,
        replace_jur NVARCHAR2(10) DEFAULT 'FALSE',
        excess decimal(22, 10) DEFAULT 0 not null,
        create_date	timestamp not null,
        update_date	timestamp,
        constraint pk_t_tax_billsoft_override primary key(id_tax_override)
        )
      