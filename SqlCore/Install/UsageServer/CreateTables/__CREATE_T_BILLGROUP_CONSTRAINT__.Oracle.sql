
CREATE TABLE t_billgroup_constraint
(
  id_usage_interval number(10) NOT NULL,
  id_group number(10) NOT NULL,
  id_acc number(10) NOT NULL,  
  CONSTRAINT FK1_t_billgroup_constraint FOREIGN KEY (id_usage_interval) REFERENCES t_usage_interval (id_interval),
  CONSTRAINT FK2_t_billgroup_constraint FOREIGN KEY (id_acc) REFERENCES t_account (id_acc)
)
	 