
CREATE TABLE t_billgroup_member_history
(
  id_billgroup INT NULL,           
  id_acc INT NOT NULL, 
  id_materialization INT NOT NULL, 
  tx_status VARCHAR(10) NOT NULL, 
  tt_start DATETIME NOT NULL, 
  tt_end DATETIME NOT NULL,
  tx_failure_reason VARCHAR(2048) NULL,
  
  CONSTRAINT FK1_t_billgroup_member_history FOREIGN KEY (id_acc) REFERENCES t_account (id_acc),  
  CONSTRAINT FK2_t_billgroup_member_history FOREIGN KEY (id_materialization) REFERENCES t_billgroup_materialization (id_materialization)
)
create clustered index idx_billgroup_member_history on t_billgroup_member_history(id_materialization)
	 