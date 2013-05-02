
        create table t_tax_billsoft_pc_map (
        product_code		nvarchar(255)	not null	default 'BADCODE',
        transaction_type	int				not null,
        service_type		int				not null,
        constraint pk_t_tax_billsoft_pc_map primary key(product_code)
        )
      