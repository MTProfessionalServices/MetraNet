
        create table t_tax_vendor_params (
        id_vendor int not null,
        tx_canonical_name varchar(255) not null,
        tx_type varchar(255) not null,
        tx_default varchar(255) not null,
        tx_description varchar(2000) not null,
        tx_direction int NULL,
        constraint pk_t_tax_vendor_params_id_vendor primary key(id_vendor, tx_canonical_name)
        )
      
