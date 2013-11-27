
        create table t_failed_transaction_msix
        (
            id_failed_transaction number(10),
            n_row	number(10),
            tx_text varchar2(2048),
            CONSTRAINT FK1_t_failed_transaction_msix FOREIGN KEY (id_failed_transaction) REFERENCES t_failed_transaction (id_failed_transaction)
        )
        