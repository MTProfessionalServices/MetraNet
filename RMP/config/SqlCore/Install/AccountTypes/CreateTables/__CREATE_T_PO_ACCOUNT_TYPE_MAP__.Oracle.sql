
create table t_po_account_type_map
(
  id_po number(10) NOT NULL,
  id_account_type number(10) NOT NULL,
  CONSTRAINT pk_t_po_account_type_map PRIMARY KEY (id_po, id_account_type)
)
			