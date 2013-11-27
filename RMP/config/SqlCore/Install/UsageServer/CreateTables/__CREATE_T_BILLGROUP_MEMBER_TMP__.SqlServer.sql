
CREATE TABLE t_billgroup_member_tmp
(
  id_materialization INT NOT NULL,  -- the materialization which assigned this member account to this billing group name.
  tx_name NVARCHAR(50) NOT NULL,    -- name of this billing group
  id_acc INT NOT NULL,              -- member account assigned to this billing group name.
  b_extra INT NULL                  -- 1, if this account is added to satisfy billing group constraints during pull list creation, else NULL
 
  CONSTRAINT FK1_t_billgroup_member_tmp 
    FOREIGN KEY (id_materialization) 
    REFERENCES t_billgroup_materialization (id_materialization),

  CONSTRAINT FK2_t_billgroup_member_tmp 
    FOREIGN KEY (id_acc) 
    REFERENCES t_account (id_acc)
)
create clustered index idx_billgroup_member_tmp on t_billgroup_member_tmp(id_materialization,id_acc)
	 