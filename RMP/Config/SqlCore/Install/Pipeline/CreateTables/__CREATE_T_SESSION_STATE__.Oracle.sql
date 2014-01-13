
CREATE TABLE t_session_state
(
  id_sess raw(16) NOT NULL,
  dt_start TIMESTAMP NOT NULL,
	dt_end TIMESTAMP NOT NULL,
	tx_state CHAR(1) NOT NULL,
	id_partition number(10) DEFAULT 1 NOT NULL
	
)
PARTITION BY LIST(ID_PARTITION)
(
  PARTITION P1 VALUES(1)
)
      