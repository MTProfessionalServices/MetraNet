
CREATE TABLE t_billgroup
(
  id_billgroup INT NOT NULL,                     -- primary key
  tx_name NVARCHAR(255) NOT NULL,                 -- name of this billing group
  tx_description NVARCHAR(2048) NULL,            -- description for this billing group
  id_usage_interval INT NOT NULL,                      -- interval associated with this billing group
  id_parent_billgroup  INT NULL,                         -- id of the parent billing group, if this is the materialization of a pull list
  tx_type VARCHAR(20) NOT NULL,                     -- The type of materialization. One of: Full, Rematerialization, PullList
  id_partition  INT NULL              -- id_acc of the partition account this bill group belongs to.

  CONSTRAINT PK_t_billgroup PRIMARY KEY (id_billgroup),
  CONSTRAINT FK1_t_billgroup FOREIGN KEY (id_usage_interval) REFERENCES t_usage_interval (id_interval),
  CONSTRAINT FK2_t_billgroup FOREIGN KEY (id_parent_billgroup) REFERENCES t_billgroup (id_billgroup),
  CONSTRAINT CK1_t_billgroup CHECK (tx_type IN ('Full', 'Rematerialization', 'PullList', 'UserDefined'))
)
	 