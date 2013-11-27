
create table t_po_account_type_map
(
  id_po int NOT NULL,
  id_account_type int NOT NULL,
  CONSTRAINT pk_t_po_account_type_map PRIMARY KEY CLUSTERED (id_po, id_account_type)
)
			