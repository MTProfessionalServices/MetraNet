  begin
      execute immediate 'CREATE table t_tax_input_%%ID_TAX_RUN%% ( 
       id_tax_charge number(19,0) not null, 
       id_sess numeric(20,0) NOT NULL,                  
       id_usage_interval number(10,0) NOT NULL,           
       charge_name varchar(255) NOT NULL,          
	   invoice_id    varchar(255) not null,
       amount numeric(22,10) not null,
       orig_pcode    number(10,0),
       term_pcode    number(10,0),
       svc_addr_pcode       number(10,0),
       customer_type varchar(255),
       invoice_date  date not null,
       is_implied_tax       varchar(255),
       round_alg     varchar(255),
       round_digits number(10,0),
       lines  number(10,0),
       location      number(10,0), 
       product_code  varchar(255),
       client_resale varchar(255),
       inc_code      varchar(255),
       id_acc number(10,0) not null, 
       is_regulated  varchar(255),
       call_duration number(20,0),
       telecom_type  varchar(255),
       svc_class_ind varchar(255),
       lifeline_flag varchar(255),
       facilities_flag      varchar(255),
       franchise_flag       varchar(255),
       bus_class_ind varchar(255),
       constraint pk_t_tax_input_%%ID_TAX_RUN%% primary key(id_tax_charge)
	   )';
      execute immediate 'CREATE SEQUENCE seq_t_tax_input_%%ID_TAX_RUN%% increment by 1 start with 1';
      end;
