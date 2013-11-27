
        create table t_tax_billsoft_override (
			id_tax_override	int identity(1,1),
			id_ancestor	int not null,
			id_acc int not null,
			pcode	int not null,
			scope	int not null,
			tax_type	int not null,
			jur_level	int not null,
			effectiveDate	datetime not null,
			levelExempt	nvarchar(10) DEFAULT 'FALSE',
			tax_rate decimal(22, 10) not null,
			maximum decimal(22, 10) not null,
			replace_jur nvarchar(10) DEFAULT 'FALSE',
			excess decimal(22, 10) not null DEFAULT 0,
			create_date	datetime not null,
			update_date	datetime,
			constraint pk_t_tax_billsoft_override primary key(id_tax_override)
        )
      