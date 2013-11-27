
CREATE TABLE t_billgroup_constraint
(
  id_usage_interval INT NOT NULL,
  id_group INT NOT NULL,
  id_acc INT NOT NULL,
  
  CONSTRAINT FK1_t_billgroup_constraint FOREIGN KEY (id_usage_interval) REFERENCES t_usage_interval (id_interval),
  CONSTRAINT FK2_t_billgroup_constraint FOREIGN KEY (id_acc) REFERENCES t_account (id_acc)
)
create clustered index idx_billgroup_constraint on t_billgroup_constraint(id_group,id_usage_interval)
	 