
      begin
      execute immediate 'CREATE table t_tax_input_%%ID_TAX_RUN%% ( 
        id_tax_charge number(10,0) not null, 
        id_sess numeric(20,0) not null, 
        id_usage_interval number(10,0) not null,
        charge_name varchar(255) not null,
        round_alg varchar(255),
        round_digits number(10,0),
        id_acc number(10,0) not null,
        amount numeric(22, 10) not null, 
        invoice_date date not null, 
        product_code varchar(255) not null, 
		is_implied_tax varchar(1),
		tax_informational varchar(1),
        constraint pk_t_tax_input_%%ID_TAX_RUN%% primary key(id_tax_charge)
        )';
      execute immediate 'CREATE SEQUENCE seq_t_tax_input_%%ID_TAX_RUN%% increment by 1 start with 1';
      end;
	  