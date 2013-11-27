
create global temporary table tmp_billUnassignedAccountMoves (
  id_materialization INT NOT NULL, 
  id_acc INT NOT NULL,
  id_billgroup INT NOT NULL,
  billgroup_name NVARCHAR2(50) NOT NULL,
  status VARCHAR2(1))
		