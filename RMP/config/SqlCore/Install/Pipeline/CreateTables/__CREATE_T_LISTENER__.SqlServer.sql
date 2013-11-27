
CREATE TABLE t_listener
(
  -- unique listener ID
  id_listener INT IDENTITY(1,1) NOT NULL constraint pk_t_listener PRIMARY KEY,
  -- machine name
  tx_machine VARCHAR(256),

  -- flag indicating if this listener is online or not
  b_online CHAR(1) NOT NULL
)
ALTER TABLE t_listener ADD CONSTRAINT uk_t_listener_tx_machine UNIQUE (tx_machine)
			