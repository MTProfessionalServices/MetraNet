
CREATE TABLE t_billgroup_member
(
  id_billgroup number(10) NULL,                 
  id_acc number(10) NOT NULL,                  
  id_materialization number(10) NOT NULL,      
  id_root_billgroup number(10) NULL,
  CONSTRAINT FK1_t_billgroup_member FOREIGN KEY (id_billgroup) REFERENCES t_billgroup (id_billgroup),
  CONSTRAINT FK2_t_billgroup_member FOREIGN KEY (id_acc) REFERENCES t_account (id_acc),  
  CONSTRAINT FK3_t_billgroup_member FOREIGN KEY (id_materialization) REFERENCES t_billgroup_materialization (id_materialization)
)
	 