
CREATE TABLE t_recevent_inst
(
  id_instance INT IDENTITY(1000,1) NOT NULL,
  id_event INT NOT NULL,
  id_arg_interval INT NULL,   -- usage interval that an end-of-period adapter is to operate on
  id_arg_billgroup INT NULL,  -- billing group that an end-of-period adapter is to operate on
  id_arg_root_billgroup INT NULL,  -- root billing group that an end-of-period adapter is to operate on
  dt_arg_start DATETIME NULL, -- start date that a scheduled adapter is to operate on
  dt_arg_end DATETIME NULL,   -- end date that a scheduled adapter is to operate on
  b_ignore_deps VARCHAR(1) NOT NULL, -- whether to ignore dependencies for this instance
  dt_effective DATETIME NULL, -- this instance can only run after this date, not before
  tx_status VARCHAR(14) NOT NULL, -- the status of the instance based on the latest run
  CONSTRAINT PK_t_recevent_inst PRIMARY KEY (id_instance),
  CONSTRAINT FK1_t_recevent_inst FOREIGN KEY (id_event) REFERENCES t_recevent (id_event),
--  CONSTRAINT FK2_t_recevent_inst FOREIGN KEY (id_arg_interval) REFERENCES t_pc_interval (id_interval),
  CONSTRAINT CK1_t_recevent_inst CHECK ((dt_arg_start IS NULL AND dt_arg_end IS NULL) OR
                                       (dt_arg_start IS NOT NULL AND dt_arg_end IS NOT NULL)),
  CONSTRAINT CK2_t_recevent_inst CHECK (b_ignore_deps IN ('N' , 'Y')),
  CONSTRAINT CK3_t_recevent_inst CHECK (tx_status IN ('NotYetRun', 'ReadyToRun', 'ReadyToReverse',
                                                      'Running', 'Reversing', 'Succeeded', 'Failed'))
)
			 