
        CREATE TABLE t_batch_history (
        id_batch_history int identity (1,1) NOT NULL,
        tx_batch varbinary (16) NOT NULL,
        tx_batch_encoded varchar (255) NOT NULL,
        tx_status char(1) NOT NULL,
        dt_first datetime,
        dt_last datetime,
        n_completed int NOT NULL,
        n_failed int NOT NULL,
        n_dismissed int NULL default 0,
        n_expected int,
        n_metered int,
		dt_history_crt datetime NOT NULL default GETUTCDATE(),
        CONSTRAINT PK_t_batch_history PRIMARY KEY CLUSTERED (id_batch_history))
      