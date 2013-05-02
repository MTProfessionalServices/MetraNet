
        create table t_adjustment_type (
        id_prop number(10) primary key not null,
        tx_guid RAW(16) null,
        id_pi_type NUMBER(10) not null,
        n_adjustmentType NUMBER(10) not null, /* adjustment enumerated type */
        b_supportBulk char(1) not null,
        id_formula NUMBER(10) NOT NULL,
        tx_default_desc nclob null,
        n_composite_adjustment NUMBER(10) DEFAULT (0) NOT NULL ,
        CONSTRAINT adj_bulkcheck CHECK  (b_supportBulk = 'Y' or b_supportBulk = 'N')
        )
      