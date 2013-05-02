
CREATE TABLE t_billgroup_materialization
(
  id_materialization INT IDENTITY(1000,1) NOT NULL,   -- identity and primary key
  id_user_acc INT NOT NULL,                                         -- user who performed the action.
  dt_start DATETIME NOT NULL,                                     -- date this materialization started
  dt_end DATETIME NULL,                                              -- date this materialization ended
  id_parent_billgroup  INT NULL,                                    -- id of the parent billing group, if this is the materialization of a pull list
  id_usage_interval INT NOT NULL,                                -- interval associated with this billing group 
  tx_status VARCHAR(10) NOT NULL,                             -- The status of the materialization process. 
                                                                                      --  One of the following:InProgress, Succeeded, Failed, Aborted 
  tx_failure_reason VARCHAR(4096),                             -- This will contain a description of the error if any occur.
  tx_type VARCHAR(20) NOT NULL                                -- The type of materialization. One of: Full, Rematerialization, PullList 

  CONSTRAINT PK_t_billgroup_materialization PRIMARY KEY (id_materialization),
  CONSTRAINT FK1_t_billgroup_materialization FOREIGN KEY (id_user_acc) REFERENCES t_account (id_acc),
  CONSTRAINT FK3_t_billgroup_materialization FOREIGN KEY (id_usage_interval) REFERENCES t_usage_interval (id_interval),  
  CONSTRAINT CK1_t_billgroup_materialization CHECK (tx_status IN ('InProgress', 'Succeeded', 'Failed', 'Aborted')),
  CONSTRAINT CK2_t_billgroup_materialization CHECK (tx_type IN ('Full', 'Rematerialization', 'PullList', 'UserDefined'))
)
	 