
        CREATE TABLE t_batch_history (
        id_batch_history number(10) NOT NULL,
        tx_batch raw (16) NOT NULL,
        tx_batch_encoded varchar2 (255) NOT NULL,
        tx_status char(1) NOT NULL,
        dt_first date,
        dt_last date,
        n_completed number(10) NOT NULL,
        n_failed number(10) NOT NULL,
        n_dismissed number(10) default (0),
        n_expected number(10),
        n_metered number(10),
		dt_history_crt date default sys_extract_utc(systimestamp),
        CONSTRAINT PK_t_batch_history PRIMARY KEY (id_batch_history))
      