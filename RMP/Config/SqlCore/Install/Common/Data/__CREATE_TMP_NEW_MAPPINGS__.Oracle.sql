
        create global temporary table tmp_new_mappings
        (
            id_acc NUMBER(10) NOT NULL,
            id_usage_interval NUMBER(10) NOT NULL,
            tx_status VARCHAR2(1) NOT NULL
        )
        on commit preserve rows
    