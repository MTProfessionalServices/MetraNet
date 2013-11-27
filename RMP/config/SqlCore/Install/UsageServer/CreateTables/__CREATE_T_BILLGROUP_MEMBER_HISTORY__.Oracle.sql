
CREATE TABLE t_billgroup_member_history
(
  id_billgroup number(10) NULL,           
  id_acc number(10) NOT NULL, 
  id_materialization number(10) NOT NULL, 
  tx_status VARCHAR2(10) NOT NULL, 
  tt_start DATE NOT NULL, 
  tt_end DATE NOT NULL,
  tx_failure_reason VARCHAR2(2048) NULL,  
  CONSTRAINT FK1_t_billgroup_member_history FOREIGN KEY (id_acc) REFERENCES t_account (id_acc),  
  CONSTRAINT FK2_t_billgroup_member_history FOREIGN KEY (id_materialization) REFERENCES t_billgroup_materialization (id_materialization)
)
	 