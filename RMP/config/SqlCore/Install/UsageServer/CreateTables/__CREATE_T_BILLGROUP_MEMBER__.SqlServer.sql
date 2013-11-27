
CREATE TABLE t_billgroup_member
(
  id_billgroup INT NULL,                 -- the billing group identifier
  id_acc INT NOT NULL,                   -- account which has been mapped to the billing group specified by id_billgroup 
  id_materialization INT NOT NULL,       -- the materialization which assigned the member account to this billing group
  id_root_billgroup INT NULL             -- the root billgroup id for a pull list
  
  CONSTRAINT FK1_t_billgroup_member FOREIGN KEY (id_billgroup) REFERENCES t_billgroup (id_billgroup),
  CONSTRAINT FK2_t_billgroup_member FOREIGN KEY (id_acc) REFERENCES t_account (id_acc),  
  CONSTRAINT FK3_t_billgroup_member FOREIGN KEY (id_materialization) REFERENCES t_billgroup_materialization (id_materialization)
)
create unique clustered index idx_billgroup_member on t_billgroup_member(id_billgroup,id_acc)
	 