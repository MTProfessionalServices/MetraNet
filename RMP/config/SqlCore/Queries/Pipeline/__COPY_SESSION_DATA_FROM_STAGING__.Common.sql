
INSERT INTO t_session (id_ss, id_source_sess)
SELECT * FROM %%%NETMETERSTAGE_PREFIX%%%t_session %%%READCOMMITTED%%%
			