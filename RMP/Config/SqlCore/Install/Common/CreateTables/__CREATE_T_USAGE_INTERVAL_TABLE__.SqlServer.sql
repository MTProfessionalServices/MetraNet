
CREATE TABLE t_usage_interval
(
  id_interval INT NOT NULL,
  id_usage_cycle int NOT NULL,
  dt_start datetime NOT NULL,
  dt_end datetime NOT NULL,
  tx_interval_status CHAR(1) NOT NULL,
  CONSTRAINT PK_t_usage_interval PRIMARY KEY CLUSTERED (id_interval),
  CONSTRAINT CK1_t_usage_interval CHECK (tx_interval_status IN ('O', 'B', 'H'))
    -- if the tx_interval_status is 'B' (blocked), then no new accounts can be mapped to this interval
)
CREATE INDEX time_usage_interval_index ON t_usage_interval (dt_start, dt_end)
		