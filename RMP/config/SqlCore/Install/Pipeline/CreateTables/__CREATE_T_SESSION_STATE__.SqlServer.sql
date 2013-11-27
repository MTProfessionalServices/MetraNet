
CREATE TABLE t_session_state
(
  id_sess BINARY(16) NOT NULL,
  dt_start DATETIME NOT NULL,
  dt_end DATETIME NOT NULL,
  tx_state CHAR(1) NOT NULL,
  id_partition INT NOT NULL DEFAULT 1,
  CONSTRAINT pk_t_session_state PRIMARY KEY CLUSTERED (id_sess, dt_end, tx_state) 
) 
      