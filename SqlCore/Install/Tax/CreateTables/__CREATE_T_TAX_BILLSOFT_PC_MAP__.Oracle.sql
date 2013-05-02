
        create table t_tax_billsoft_pc_map (
        product_code		nvarchar2(255)	default 'BADCODE' not null,
        transaction_type	int				not null,
        service_type		int				not null,
        constraint pk_t_tax_billsoft_pc_map primary key(product_code)
        )
      