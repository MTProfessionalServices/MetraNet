
CREATE TABLE t_billgroup
(
  id_billgroup number(10) NOT NULL,                    
  tx_name NVARCHAR2(255) NOT NULL,                
  tx_description NVARCHAR2(2000) NULL,           
  id_usage_interval number(10) NOT NULL,                     
  id_parent_billgroup  number(10) NULL,                         
  tx_type VARCHAR2(20) NOT NULL,
  id_partition  NUMBER(10) NULL,             -- id_acc of the partition account this bill group belongs to.
  CONSTRAINT PK_t_billgroup PRIMARY KEY (id_billgroup),
  CONSTRAINT FK1_t_billgroup FOREIGN KEY (id_usage_interval) REFERENCES t_usage_interval (id_interval),
  CONSTRAINT FK2_t_billgroup FOREIGN KEY (id_parent_billgroup) REFERENCES t_billgroup (id_billgroup),
  CONSTRAINT CK1_t_billgroup CHECK (tx_type IN ('Full', 'Rematerialization', 'PullList', 'UserDefined'))
)
	 