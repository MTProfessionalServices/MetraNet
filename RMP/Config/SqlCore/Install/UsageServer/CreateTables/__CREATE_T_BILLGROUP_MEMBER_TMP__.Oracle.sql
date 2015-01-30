
CREATE TABLE t_billgroup_member_tmp
(
  id_materialization number(10) NOT NULL,
  tx_name NVARCHAR2(255) NOT NULL,
  id_acc number(10) NOT NULL,
  b_extra number(10) NULL, 
  id_partition NUMBER(10) NULL,      -- id_acc of the partition account this bill group belongs to.
  CONSTRAINT FK1_t_billgroup_member_tmp FOREIGN KEY (id_materialization) REFERENCES t_billgroup_materialization (id_materialization),
  CONSTRAINT FK2_t_billgroup_member_tmp FOREIGN KEY (id_acc) REFERENCES t_account (id_acc)
)
	 