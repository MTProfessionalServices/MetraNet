
CREATE TABLE t_billgroup_source_acc
(
  id_materialization number(10) NOT NULL,    
  id_acc number(10) NOT NULL,
  CONSTRAINT FK1_t_billgroup_source_acc FOREIGN KEY (id_materialization) REFERENCES t_billgroup_materialization (id_materialization),
  CONSTRAINT FK2_t_billgroup_source_acc FOREIGN KEY (id_acc) REFERENCES t_account (id_acc)
 )
	 