
INSERT INTO t_message (id_message, id_route, dt_crt, dt_metered, dt_assigned, id_listener, id_pipeline, dt_completed, id_feedback, tx_TransactionID, tx_sc_username, tx_sc_password, tx_sc_namespace, tx_sc_serialized, tx_ip_address)
SELECT * FROM %%%NETMETERSTAGE_PREFIX%%%t_message %%%READCOMMITTED%%%
			