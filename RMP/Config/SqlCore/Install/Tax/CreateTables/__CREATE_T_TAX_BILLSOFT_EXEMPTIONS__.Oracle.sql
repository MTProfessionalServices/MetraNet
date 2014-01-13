
        create table t_tax_billsoft_exemptions (
        id_tax_exemption int not null,
        id_ancestor	int not null,
        id_acc int not null,
        certificate_id nvarchar2(255),
        pcode int not null,
        tax_type int not null,
        jur_level int not null,
        start_date	timestamp not null,
        end_date	timestamp not null,
        create_date	timestamp not null,
        update_date	timestamp,
        constraint pk_t_tax_billsoft_exemptions primary key(id_tax_exemption)
        )
      