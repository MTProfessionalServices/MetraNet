
create table t_tax_input_%%ID_TAX_RUN%%
(
       id_tax_charge int,
       invoice_id    varchar(255),
       amount decimal,
       orig_pcode    int,
       term_pcode    int,
       svc_addr_pcode       int,
       customer_type varchar(255),
       invoice_date  date,
       is_implied_tax       varchar(255),
       round_alg     varchar(255),
       round_digits int,
       lines  int,
       location      int, 
       product_code  varchar(255),
       client_resale varchar(255),
       inc_code      varchar(255),
       id_acc int, 
       is_regulated  varchar(255),
       call_duration decimal,
       telecom_type  varchar(255),
       svc_class_ind varchar(255),
       lifeline_flag varchar(255),
       facilities_flag      varchar(255),
       franchise_flag       varchar(255),
       bus_class_ind varchar(255)
       )
      