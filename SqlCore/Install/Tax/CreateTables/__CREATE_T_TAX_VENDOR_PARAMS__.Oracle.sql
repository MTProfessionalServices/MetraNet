
    create table t_tax_vendor_params (
    id_vendor number(10),
    tx_canonical_name varchar2(255) not null,
    tx_type varchar2(255) not null,
    tx_default varchar2(255) not null,
    tx_description varchar2(2000) not null,
    tx_direction number(10) NULL,
    constraint pk_t_tax_vendor_params_id_vend primary key(id_vendor,tx_canonical_name)
    )
		
