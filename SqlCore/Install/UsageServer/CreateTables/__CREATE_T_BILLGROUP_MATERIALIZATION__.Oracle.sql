
CREATE TABLE t_billgroup_materialization
(
  id_materialization number(10) NOT NULL,   
  id_user_acc number(10) NOT NULL,                                         
  dt_start DATE NOT NULL,                                     
  dt_end DATE NULL,                                              
  id_parent_billgroup  number(10) NULL,                                    
  id_usage_interval number(10) NOT NULL,                                
  tx_status VARCHAR2(10) NOT NULL,
  tx_failure_reason VARCHAR2(4000),
  tx_type VARCHAR2(20) NOT NULL,
  CONSTRAINT PK_t_billgroup_materialization PRIMARY KEY (id_materialization),
  CONSTRAINT FK1_billgroup_materialization FOREIGN KEY (id_user_acc) REFERENCES t_account (id_acc),
  CONSTRAINT FK3_billgroup_materialization FOREIGN KEY (id_usage_interval) REFERENCES t_usage_interval (id_interval),  
  CONSTRAINT CK1_billgroup_materialization CHECK (tx_status IN ('InProgress', 'Succeeded', 'Failed', 'Aborted')),
  CONSTRAINT CK2_billgroup_materialization CHECK (tx_type IN ('Full', 'Rematerialization', 'PullList', 'UserDefined'))
)
	 