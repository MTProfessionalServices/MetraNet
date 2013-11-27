
INSERT INTO t_session_set (id_message, id_ss, id_svc, b_root, session_count)
SELECT * FROM %%%NETMETERSTAGE_PREFIX%%%t_session_set %%%READCOMMITTED%%%
			