
          CREATE TABLE t_recur
          (
          id_prop INT NOT NULL,
          b_advance CHAR(1) NOT NULL,
          b_prorate_on_deactivate CHAR(1) NOT NULL,
          b_prorate_instantly CHAR(1) NOT NULL,
          b_prorate_on_activate CHAR(1) NOT NULL,
          b_prorate_on_rate_change CHAR(1) NOT NULL,
          b_fixed_proration_length CHAR(1) NOT NULL,
          id_usage_cycle INT,
          id_cycle_type INT,
          tx_cycle_mode VARCHAR(30) NOT NULL,
          b_charge_per_participant CHAR(1) NOT NULL,
          n_unit_name INT NULL,
          nm_unit_name NVARCHAR(255) NOT NULL,
          n_unit_display_name INT NULL,
          nm_unit_display_name NVARCHAR(255) NULL,
          n_rating_type INT NOT NULL,
          b_integral CHAR(1) NOT NULL,
          max_unit_value DECIMAL(22,10) NOT NULL,
          min_unit_value DECIMAL(22,10) NOT NULL,
          CONSTRAINT pk_t_recur PRIMARY KEY (id_prop),
          CONSTRAINT CK1_t_recur CHECK (tx_cycle_mode IN ('Fixed', 'BCR', 'BCR Constrained', 'EBCR'))
          )
        