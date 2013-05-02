
create table t_failed_transaction_msix
(
  id_failed_transaction int,
  n_row	int,
  tx_text varchar(2048),
  CONSTRAINT FK1_t_failed_transaction_msix FOREIGN KEY (id_failed_transaction) REFERENCES t_failed_transaction (id_failed_transaction)
)
		  