
        create global temporary table tmp_new_intervals
        (
            id_interval NUMBER(10) NOT NULL,
            id_usage_cycle NUMBER(10) NOT NULL,
            dt_start DATE NOT NULL,
            dt_end DATE NOT NULL,
            tx_interval_status VARCHAR2(1) NOT NULL,
            id_cycle_type NUMBER(10) NOT NULL
        )
    