
        CREATE TABLE t_batch (
        id_batch int identity (1,1) NOT NULL,
        tx_batch varbinary (16) NOT NULL,
        tx_batch_encoded varchar (255) NOT NULL,
        tx_source varchar(255),
        tx_sequence varchar(255) NULL,
        tx_name nvarchar(128) NOT NULL,
        tx_namespace nvarchar(128) NOT NULL,
        tx_status char(1) NOT NULL,
        dt_crt_source datetime,
        dt_crt datetime NOT NULL,
        dt_first datetime,
        dt_last datetime,
        n_completed int NOT NULL,
        n_failed int NOT NULL,
        n_dismissed int NULL default 0,
        n_expected int,
        n_metered int,
        CONSTRAINT PK_t_batch PRIMARY KEY CLUSTERED (id_batch),
        CONSTRAINT tx_status_check CHECK (
        UPPER(tx_status) = 'A' OR UPPER(tx_status) = 'B' OR	UPPER(tx_status) = 'F' OR
        UPPER(tx_status) = 'D' OR UPPER(tx_status) = 'C'),
        CONSTRAINT UK_1_t_batch UNIQUE (tx_batch),
        CONSTRAINT UK_2_t_batch UNIQUE (tx_name, tx_namespace, tx_sequence),
        CONSTRAINT UK_3_t_batch CHECK (n_completed >= 0),
        -- this constraint is commented out as temporary workaround for CR10628
				-- CONSTRAINT UK_4_t_batch CHECK (n_failed >= 0),
				CONSTRAINT UK_5_t_batch CHECK (n_expected >= 0),
				CONSTRAINT UK_6_t_batch CHECK (n_metered >= 0),
        CONSTRAINT UK_7_t_batch CHECK (n_dismissed >= 0))
      