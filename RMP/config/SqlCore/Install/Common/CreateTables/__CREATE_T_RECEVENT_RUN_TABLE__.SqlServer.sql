
CREATE TABLE t_recevent_run
(
  id_run INT NOT NULL,
  id_instance INT NOT NULL,
  tx_type VARCHAR(7) NOT NULL,      -- what the run will do
  id_reversed_run INT NULL,         -- the reversed run, null if the type is 'Execute'
  tx_machine VARCHAR(128) NOT NULL, -- machine on which the event is processed
  dt_start DATETIME NOT NULL,       -- time the run began
  dt_end DATETIME NULL,             -- time the run finished
  tx_status nvarchar(10) NOT NULL,   -- status of the run
  tx_detail nvarchar(2048) NULL,     -- any details relating to the result of the action
  CONSTRAINT PK1_t_recevent_run PRIMARY KEY (id_run),
  CONSTRAINT FK1_t_recevent_run FOREIGN KEY (id_instance) REFERENCES t_recevent_inst (id_instance),
  CONSTRAINT CK1_t_recevent_run CHECK (tx_type IN ('Execute' , 'Reverse')),
  CONSTRAINT CK2_t_recevent_run CHECK (tx_status IN ('InProgress', 'Succeeded', 'Failed'))
)
			 