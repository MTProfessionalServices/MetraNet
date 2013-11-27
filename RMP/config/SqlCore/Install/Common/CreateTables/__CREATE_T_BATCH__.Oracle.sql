
      CREATE TABLE t_batch (
      id_batch number(10) NOT NULL,
      tx_batch raw (16) NOT NULL,
      tx_batch_encoded varchar2 (255) NOT NULL,
      tx_source varchar2(255),
      tx_sequence varchar2(255),
      tx_name nvarchar2(128) NOT NULL,
      tx_namespace nvarchar2(128) NOT NULL,
      tx_status char(1) NOT NULL,
      dt_crt_source date,
      dt_crt date NOT NULL,
      dt_first date,
      dt_last date,
      n_completed number(10) NOT NULL,
      n_failed number(10) NOT NULL,
      n_dismissed number(10) DEFAULT (0),
      n_expected number(10),
      n_metered number(10),
      CONSTRAINT PK_t_batch PRIMARY KEY (id_batch),
      CONSTRAINT tx_status_check CHECK (
      UPPER(tx_status) = 'A' OR
      UPPER(tx_status) = 'B' OR
      UPPER(tx_status) = 'F' OR
      UPPER(tx_status) = 'D' OR
      UPPER(tx_status) = 'C'),
      CONSTRAINT UK_1_t_batch UNIQUE (tx_batch),
      CONSTRAINT UK_2_t_batch UNIQUE (tx_name, tx_namespace, tx_sequence),
      CONSTRAINT UK_3_t_batch CHECK (n_completed >= 0),
        /* this constraint is commented out as temporary workaround for CR10628 */
				/* CONSTRAINT UK_4_t_batch CHECK (n_failed >= 0), */
		CONSTRAINT UK_5_t_batch CHECK (n_expected >= 0),
		CONSTRAINT UK_6_t_batch CHECK (n_metered >= 0),
    CONSTRAINT UK_7_t_batch CHECK (n_dismissed >= 0))
    