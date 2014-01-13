
          create table T_RECUR (
          ID_PROP NUMBER(10) not null,
          B_ADVANCE CHAR(1) not null,
          B_PRORATE_ON_DEACTIVATE CHAR(1) not null,
          b_prorate_instantly CHAR(1) NOT NULL,
          B_PRORATE_ON_ACTIVATE CHAR(1) not null,
          b_prorate_on_rate_change char(1) not null,
          b_fixed_proration_length char(1) not null,
          ID_USAGE_CYCLE NUMBER(10),
          id_cycle_type number(10),
          tx_cycle_mode varchar2(30) not null,
          b_charge_per_participant char(1) not null,
          n_unit_name number(10) null,
          nm_unit_name nvarchar2(255) not null,
          n_unit_display_name number(10) null,
          nm_unit_display_name nvarchar2(255) null,
          n_rating_type number(10) not null,
          b_integral char(1) not null,
          max_unit_value number(22,10) not null,
          min_unit_value number(22,10) not null,
          constraint T_RECUR_PK primary key (ID_PROP),
          CONSTRAINT CK1_t_recur CHECK (tx_cycle_mode IN ('Fixed', 'BCR', 'BCR Constrained', 'EBCR')))
        