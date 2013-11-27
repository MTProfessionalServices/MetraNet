
CREATE TABLE t_billgroup_source_acc
(
  id_materialization INT NOT NULL,    -- the materialization for which this account is used as a source
  id_acc INT NOT NULL,                -- source account for this materialization
 
  CONSTRAINT FK1_t_billgroup_source_acc FOREIGN KEY (id_materialization) REFERENCES t_billgroup_materialization (id_materialization),
  CONSTRAINT FK2_t_billgroup_source_acc FOREIGN KEY (id_acc) REFERENCES t_account (id_acc)
 )
create clustered index idx_billgroup_source_acc on t_billgroup_source_acc(id_materialization,id_acc)
	 