
        CREATE TABLE t_recevent_run_batch (
            id_run number(10) NOT NULL,
            tx_batch_encoded VARCHAR2(255) NOT NULL,
            CONSTRAINT FK1_t_recevent_run_batch FOREIGN KEY (id_run)
            REFERENCES t_recevent_run (id_run))
        