
        create table t_tax_billsoft_exemptions (
          id_tax_exemption int identity(1,1),
          id_ancestor	int not null,
          id_acc int not null,
          certificate_id nvarchar(255),
          pcode int not null,
          tax_type int not null,
          jur_level int not null,
          start_date	datetime not null,
          end_date	datetime not null,
          create_date	datetime not null,
          update_date	datetime,
          constraint pk_t_tax_billsoft_exemptions primary key(id_tax_exemption)
        )
      