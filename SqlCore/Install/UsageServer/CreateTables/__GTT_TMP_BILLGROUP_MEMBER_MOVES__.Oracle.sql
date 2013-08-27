
  create global temporary table tmp_billGroupMemberMoves (
    id_materialization_new INT NOT NULL, 
    id_materialization_old INT NOT NULL,
    id_acc INT NOT NULL,
    id_billgroup_new INT NOT NULL,
    id_billgroup_old INT NOT NULL,
    billgroup_name_new NVARCHAR2(50) NOT NULL,
    billgroup_name_old NVARCHAR2(50) NOT NULL,
    newStatus VARCHAR2(1),
    oldStatus VARCHAR2(1) NOT NULL
    )
		