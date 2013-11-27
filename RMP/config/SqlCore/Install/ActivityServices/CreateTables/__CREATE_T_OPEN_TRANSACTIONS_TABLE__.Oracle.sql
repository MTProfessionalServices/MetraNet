
				create table t_open_transactions (
					id_payment_transaction VARCHAR2(40) NOT NULL,
					PRIMARY KEY (id_payment_transaction),
					CONSTRAINT FK_t_open_transactions_table FOREIGN KEY (id_payment_transaction) 
            REFERENCES t_payment_history (id_payment_transaction)
				)
			